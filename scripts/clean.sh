#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd -- "${SCRIPT_DIR}/.." && pwd)"

BUILD_DIR="${BUILD_DIR:-${PROJECT_ROOT}/build}"
BIN_DIR="${BIN_DIR:-${PROJECT_ROOT}/bin}"

rm -rf -- "${BUILD_DIR}" "${BIN_DIR}"

echo "Cleaned build output."
