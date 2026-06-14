#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd -- "${SCRIPT_DIR}/.." && pwd)"

BUILD_DIR="${BUILD_DIR:-${PROJECT_ROOT}/build}"
BINARY_NAME="${BINARY_NAME:-pacman-opengl}"

usage() {
    echo "Usage: ./scripts/build_and_run.sh [--clean]"
}

detect_platform() {
    case "$(uname -s)" in
        MINGW*|MSYS*|CYGWIN*) echo "windows" ;;
        *) echo "native" ;;
    esac
}

args=()
if [[ $# -gt 0 ]]; then
    for arg in "$@"; do
        case "${arg}" in
            --clean)
                args+=("--clean")
                ;;
            -h|--help)
                usage
                exit 0
                ;;
            *)
                usage >&2
                echo "build_and_run.sh: unknown argument: ${arg}" >&2
                exit 1
                ;;
        esac
    done
fi

"${SCRIPT_DIR}/build.sh" "${args[@]+"${args[@]}"}"

exe_ext=""
if [[ "$(detect_platform)" == "windows" ]]; then
    exe_ext=".exe"
fi

binary="${BUILD_DIR}/${BINARY_NAME}${exe_ext}"
if [[ ! -f "${binary}" ]]; then
    echo "build_and_run.sh: built binary was not found: ${binary}" >&2
    exit 1
fi

echo "Running ${binary}"
"${binary}"
