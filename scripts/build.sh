#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd -- "${SCRIPT_DIR}/.." && pwd)"

EXTERNAL_DIR="${EXTERNAL_DIR:-${PROJECT_ROOT}/external}"
INCLUDE_DIR="${EXTERNAL_DIR}/include"
LIB_DIR="${EXTERNAL_DIR}/lib"
BUILD_DIR="${BUILD_DIR:-${PROJECT_ROOT}/build}"
BINARY_NAME="${BINARY_NAME:-pacman-opengl}"
MAIN_SOURCE="${MAIN_SOURCE:-${PROJECT_ROOT}/source/main.cpp}"

usage() {
    echo "Usage: ./scripts/build.sh [--clean]"
}

die() {
    echo "build.sh: $*" >&2
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

    if command -v g++ >/dev/null 2>&1; then
        return 0
    fi

    local candidate
    for candidate in /c/msys64/ucrt64/bin /c/msys64/mingw64/bin /c/msys64/clang64/bin; do
        if [[ -d "${candidate}" ]]; then
            export PATH="${candidate}:${PATH}"
            if command -v g++ >/dev/null 2>&1; then
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

require_setup() {
    local missing=()

    [[ -d "${INCLUDE_DIR}/GLFW" ]] || missing+=("${INCLUDE_DIR}/GLFW")
    [[ -d "${INCLUDE_DIR}/glm" ]] || missing+=("${INCLUDE_DIR}/glm")
    [[ -d "${INCLUDE_DIR}/glad" ]] || missing+=("${INCLUDE_DIR}/glad")
    [[ -f "${INCLUDE_DIR}/imgui.h" ]] || missing+=("${INCLUDE_DIR}/imgui.h")
    [[ -f "${LIB_DIR}/libglfw3.a" ]] || missing+=("${LIB_DIR}/libglfw3.a")
    [[ -f "${LIB_DIR}/libglad.a" ]] || missing+=("${LIB_DIR}/libglad.a")
    [[ -f "${LIB_DIR}/libimgui.a" ]] || missing+=("${LIB_DIR}/libimgui.a")

    if (( ${#missing[@]} > 0 )); then
        echo "build.sh: dependencies are missing. Run ./scripts/setup.sh first." >&2
        echo "Missing:" >&2
        local item
        for item in "${missing[@]}"; do
            echo "  ${item}" >&2
        done
        exit 1
    fi
}

clean_first=false
for arg in "$@"; do
    case "${arg}" in
        --clean)
            clean_first=true
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            usage >&2
            die "unknown argument: ${arg}"
            ;;
    esac
done

if [[ "${clean_first}" == "true" ]]; then
    "${SCRIPT_DIR}/clean.sh"
fi

require_setup
[[ -f "${MAIN_SOURCE}" ]] || die "main source not found: ${MAIN_SOURCE}"

PLATFORM="$(detect_platform)" || die "unsupported platform: $(uname -s)"
if [[ "${PLATFORM}" == "windows" ]]; then
    add_mingw_to_path_if_present || die "MinGW tools were not found. Install MSYS2 UCRT64/MinGW and put its bin directory on PATH."
fi

CXX="${CXX:-$(find_tool g++ clang++ c++ || true)}"
[[ -n "${CXX}" ]] || die "a C++ compiler is required"

EXE_EXT=""
system_libs=()
case "${PLATFORM}" in
    windows)
        EXE_EXT=".exe"
        system_libs=(-lopengl32 -lgdi32 -luser32 -lshell32 -lole32 -luuid -lcomdlg32)
        ;;
    macos)
        system_libs=(-framework OpenGL -framework Cocoa -framework IOKit -framework QuartzCore -framework CoreFoundation)
        ;;
    linux)
        system_libs=(-lGL -lX11 -lXrandr -lXi -lXcursor -lXinerama -ldl -lpthread -lrt -lm)
        ;;
esac

output="${BUILD_DIR}/${BINARY_NAME}${EXE_EXT}"
mkdir -p -- "${BUILD_DIR}"

extra_cxxflags=()
extra_ldflags=()
if [[ -n "${CXXFLAGS:-}" ]]; then
    read -r -a extra_cxxflags <<< "${CXXFLAGS}"
fi
if [[ -n "${LDFLAGS:-}" ]]; then
    read -r -a extra_ldflags <<< "${LDFLAGS}"
fi

echo "Building ${output}"
build_cmd=(
    "${CXX}"
    -std=c++20
    -Wall
    -Wextra
    -Wpedantic
    -DIMGUI_IMPL_OPENGL_LOADER_GLAD2
    -I"${INCLUDE_DIR}"
)

if (( ${#extra_cxxflags[@]} > 0 )); then
    build_cmd+=("${extra_cxxflags[@]}")
fi

build_cmd+=(
    "${MAIN_SOURCE}"
    "${LIB_DIR}/libimgui.a"
    "${LIB_DIR}/libglfw3.a"
    "${LIB_DIR}/libglad.a"
)

build_cmd+=("${system_libs[@]}")

if (( ${#extra_ldflags[@]} > 0 )); then
    build_cmd+=("${extra_ldflags[@]}")
fi

build_cmd+=(-o "${output}")

"${build_cmd[@]}"

echo "Built ${output}"
