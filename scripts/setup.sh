#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd -- "${SCRIPT_DIR}/.." && pwd)"

EXTERNAL_DIR="${EXTERNAL_DIR:-${PROJECT_ROOT}/external}"
INCLUDE_DIR="${EXTERNAL_DIR}/include"
LIB_DIR="${EXTERNAL_DIR}/lib"
WORK_DIR="${EXTERNAL_DIR}/_setup"
BUILD_DIR="${WORK_DIR}/build"
PY_DEPS_DIR="${WORK_DIR}/python"

cleanup_work_dir() {
    rm -rf -- "${WORK_DIR}"
}

die() {
    echo "setup.sh: $*" >&2
    exit 1
}

find_tool() {
    local tool
    for tool in "$@"; do
        if command -v "${tool}" >/dev/null 2>&1; then
            command -v "${tool}"
            return 0
        fi
    done
    return 1
}

add_mingw_to_path_if_present() {
    if [[ -n "${MINGW_BIN:-}" && -d "${MINGW_BIN}" ]]; then
        export PATH="${MINGW_BIN}:${PATH}"
    fi

    if command -v g++ >/dev/null 2>&1 && command -v gcc >/dev/null 2>&1; then
        return 0
    fi

    local candidate
    for candidate in /c/msys64/ucrt64/bin /c/msys64/mingw64/bin /c/msys64/clang64/bin; do
        if [[ -d "${candidate}" ]]; then
            export PATH="${candidate}:${PATH}"
            if command -v g++ >/dev/null 2>&1 && command -v gcc >/dev/null 2>&1; then
                return 0
            fi
        fi
    done

    return 1
}

detect_platform() {
    case "$(uname -s)" in
        Darwin*) echo "macos" ;;
        Linux*) echo "linux" ;;
        MINGW*|MSYS*|CYGWIN*) echo "windows" ;;
        *) return 1 ;;
    esac
}

join_python_path() {
    local sep=":"
    if [[ "${PLATFORM}" == "windows" ]]; then
        sep=";"
    fi

    if [[ -n "${PYTHONPATH:-}" ]]; then
        printf '%s%s%s%s%s' "${PY_DEPS_DIR}" "${sep}" "${GLAD_SRC}" "${sep}" "${PYTHONPATH}"
    else
        printf '%s%s%s' "${PY_DEPS_DIR}" "${sep}" "${GLAD_SRC}"
    fi
}

clone_latest() {
    local name="$1"
    local url="$2"
    local target="$3"

    echo "Cloning latest ${name}..."
    git clone --depth 1 "${url}" "${target}"
}

compile_c() {
    local out="$1"
    local src="$2"
    shift 2

    mkdir -p -- "$(dirname -- "${out}")"
    "${CC}" -O2 -DNDEBUG "$@" -c "${src}" -o "${out}"
}

compile_cxx() {
    local out="$1"
    local src="$2"
    shift 2

    mkdir -p -- "$(dirname -- "${out}")"
    "${CXX}" -std=c++20 -O2 -DNDEBUG "$@" -c "${src}" -o "${out}"
}

compile_objc() {
    local out="$1"
    local src="$2"
    shift 2

    mkdir -p -- "$(dirname -- "${out}")"
    "${CC}" -x objective-c -O2 -DNDEBUG "$@" -c "${src}" -o "${out}"
}

make_static_library() {
    local out="$1"
    shift

    rm -f -- "${out}"
    "${AR}" rcs "${out}" "$@"
}

require_source_file() {
    local file="$1"
    [[ -f "${file}" ]] || die "required source file is missing: ${file}"
}

copy_imgui_headers() {
    mkdir -p -- "${INCLUDE_DIR}/imgui/backends"

    cp -- "${IMGUI_SRC}"/*.h "${INCLUDE_DIR}/"
    cp -- "${IMGUI_SRC}"/*.h "${INCLUDE_DIR}/imgui/"
    cp -- "${IMGUI_SRC}/backends/imgui_impl_glfw.h" "${INCLUDE_DIR}/"
    cp -- "${IMGUI_SRC}/backends/imgui_impl_opengl3.h" "${INCLUDE_DIR}/"
    cp -- "${IMGUI_SRC}/backends/imgui_impl_opengl3_loader.h" "${INCLUDE_DIR}/"
    cp -- "${IMGUI_SRC}/backends/imgui_impl_glfw.h" "${INCLUDE_DIR}/imgui/backends/"
    cp -- "${IMGUI_SRC}/backends/imgui_impl_opengl3.h" "${INCLUDE_DIR}/imgui/backends/"
    cp -- "${IMGUI_SRC}/backends/imgui_impl_opengl3_loader.h" "${INCLUDE_DIR}/imgui/backends/"
}

build_glfw() {
    echo "Building GLFW..."

    local defines=()
    local sources=(
        context.c
        init.c
        input.c
        monitor.c
        null_init.c
        null_joystick.c
        null_monitor.c
        null_window.c
        platform.c
        vulkan.c
        window.c
        egl_context.c
        osmesa_context.c
    )

    case "${PLATFORM}" in
        windows)
            defines=(-D_GLFW_WIN32 -DUNICODE -D_UNICODE)
            sources+=(
                win32_init.c
                win32_joystick.c
                win32_module.c
                win32_monitor.c
                win32_thread.c
                win32_time.c
                win32_window.c
                wgl_context.c
            )
            ;;
        macos)
            defines=(-D_GLFW_COCOA)
            sources+=(
                cocoa_init.m
                cocoa_joystick.m
                cocoa_monitor.m
                cocoa_window.m
                macos_time.c
                nsgl_context.m
                posix_module.c
                posix_thread.c
            )
            ;;
        linux)
            defines=(-D_GLFW_X11 -D_DEFAULT_SOURCE)
            sources+=(
                glx_context.c
                linux_joystick.c
                posix_module.c
                posix_poll.c
                posix_thread.c
                posix_time.c
                x11_init.c
                x11_monitor.c
                x11_window.c
                xkb_unicode.c
            )
            ;;
    esac

    local objs=()
    local src
    for src in "${sources[@]}"; do
        require_source_file "${GLFW_SRC}/src/${src}"

        local obj="${BUILD_DIR}/glfw/${src%.*}.o"
        objs+=("${obj}")

        if [[ "${src}" == *.m ]]; then
            compile_objc "${obj}" "${GLFW_SRC}/src/${src}" "${defines[@]}" -I"${GLFW_SRC}/include" -I"${GLFW_SRC}/src"
        else
            compile_c "${obj}" "${GLFW_SRC}/src/${src}" "${defines[@]}" -I"${GLFW_SRC}/include" -I"${GLFW_SRC}/src"
        fi
    done

    make_static_library "${LIB_DIR}/libglfw3.a" "${objs[@]}"
}

build_glad() {
    echo "Generating and building GLAD..."

    "${PYTHON_BIN}" -m pip install --upgrade --target "${PY_DEPS_DIR}" -r "${GLAD_SRC}/requirements.txt"

    local generated_dir="${WORK_DIR}/glad-generated"
    mkdir -p -- "${generated_dir}"

    PYTHONPATH="$(join_python_path)" "${PYTHON_BIN}" -m glad \
        --out-path "${generated_dir}" \
        --api gl:core=3.3 \
        --reproducible \
        c

    mkdir -p -- "${INCLUDE_DIR}"
    cp -R -- "${generated_dir}/include/glad" "${INCLUDE_DIR}/"
    cp -R -- "${generated_dir}/include/KHR" "${INCLUDE_DIR}/"

    compile_c "${BUILD_DIR}/glad/gl.o" "${generated_dir}/src/gl.c" -I"${generated_dir}/include"
    make_static_library "${LIB_DIR}/libglad.a" "${BUILD_DIR}/glad/gl.o"
}

build_imgui() {
    echo "Building ImGui..."

    local sources=(
        imgui.cpp
        imgui_draw.cpp
        imgui_tables.cpp
        imgui_widgets.cpp
        backends/imgui_impl_glfw.cpp
        backends/imgui_impl_opengl3.cpp
    )

    local objs=()
    local src
    for src in "${sources[@]}"; do
        require_source_file "${IMGUI_SRC}/${src}"

        local obj="${BUILD_DIR}/imgui/${src//\//_}.o"
        objs+=("${obj}")

        compile_cxx "${obj}" "${IMGUI_SRC}/${src}" \
            -DIMGUI_IMPL_OPENGL_LOADER_GLAD2 \
            -I"${INCLUDE_DIR}" \
            -I"${IMGUI_SRC}" \
            -I"${IMGUI_SRC}/backends" \
            -I"${GLFW_SRC}/include"
    done

    make_static_library "${LIB_DIR}/libimgui.a" "${objs[@]}"
}

PLATFORM="$(detect_platform)" || die "unsupported platform: $(uname -s)"
if [[ "${PLATFORM}" == "windows" ]]; then
    add_mingw_to_path_if_present || die "MinGW tools were not found. Install MSYS2 UCRT64/MinGW and put its bin directory on PATH."
fi

command -v git >/dev/null 2>&1 || die "git is required"

CC="${CC:-$(find_tool gcc clang cc || true)}"
CXX="${CXX:-$(find_tool g++ clang++ c++ || true)}"
AR="${AR:-$(find_tool ar llvm-ar || true)}"
PYTHON_BIN="${PYTHON:-$(find_tool python3 python || true)}"

[[ -n "${CC}" ]] || die "a C compiler is required"
[[ -n "${CXX}" ]] || die "a C++ compiler is required"
[[ -n "${AR}" ]] || die "ar or llvm-ar is required"
[[ -n "${PYTHON_BIN}" ]] || die "python3 or python is required"

cleanup_work_dir
trap cleanup_work_dir EXIT

rm -rf -- "${INCLUDE_DIR}" "${LIB_DIR}"
mkdir -p -- "${INCLUDE_DIR}" "${LIB_DIR}" "${WORK_DIR}" "${BUILD_DIR}"

GLFW_SRC="${WORK_DIR}/glfw"
GLM_SRC="${WORK_DIR}/glm"
GLAD_SRC="${WORK_DIR}/glad"
IMGUI_SRC="${WORK_DIR}/imgui"

clone_latest "GLFW" "https://github.com/glfw/glfw.git" "${GLFW_SRC}"
clone_latest "GLM" "https://github.com/g-truc/glm.git" "${GLM_SRC}"
clone_latest "GLAD" "https://github.com/Dav1dde/glad.git" "${GLAD_SRC}"
clone_latest "ImGui" "https://github.com/ocornut/imgui.git" "${IMGUI_SRC}"

cp -R -- "${GLFW_SRC}/include/GLFW" "${INCLUDE_DIR}/"
cp -R -- "${GLM_SRC}/glm" "${INCLUDE_DIR}/"
rm -f -- "${INCLUDE_DIR}/glm/"[C]MakeLists.txt
copy_imgui_headers

build_glad
build_glfw
build_imgui

echo
echo "Setup complete."
echo "Headers: ${INCLUDE_DIR}"
echo "Libraries: ${LIB_DIR}"
