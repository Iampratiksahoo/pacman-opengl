#!/usr/bin/env bash
set -euo pipefail

export PATH="/usr/bin:/bin:$PATH"

script_path="${BASH_SOURCE[0]}"
script_dir="${script_path%/*}"
if [[ "$script_dir" == "$script_path" ]]; then
  script_dir="."
fi
script_dir="$(cd -- "$script_dir" && pwd)"

if [[ -f "$script_dir/premake5.lua" ]]; then
  project_root="$script_dir"
elif [[ -f "$script_dir/../premake5.lua" ]]; then
  project_root="$(cd -- "$script_dir/.." && pwd)"
else
  echo "Could not find project root. Expected premake5.lua beside this script or one directory up." >&2
  exit 1
fi

cd "$project_root"

echo "Cleaning generated files from: $project_root"

rm -rf \
  build \
  out \
  bin \
  bin-int \
  external

rm -f \
  Makefile \
  *.make \
  *.sln \
  *.slnx \
  *.vcxproj \
  *.vcxproj.filters \
  *.vcxproj.user \
  *.cbp \
  *.workspace \
  compile_commands.json \
  imgui.ini

if [[ -d .vs ]]; then
  rm -rf .vs || echo "Warning: .vs is locked by Visual Studio. Close Visual Studio and run this again to remove it."
fi

echo "Done. Kept source, vendor, premake5.lua, README, and Git files."
