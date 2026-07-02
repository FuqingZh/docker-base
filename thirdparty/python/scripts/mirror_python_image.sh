#!/usr/bin/env bash
set -euo pipefail

source_image="python:3.8-slim-bullseye"
target_image="192.168.30.202:23099/thirdparty/python:3.8-slim-bullseye"
platform=""

usage() {
  cat <<'EOF'
Usage:
  mirror_python_image.sh [options]

Options:
  --source-image IMAGE   Source image to mirror.
                         Default: python:3.8-slim-bullseye
  --target-image IMAGE   Target Harbor image.
                         Default: 192.168.30.202:23099/thirdparty/python:3.8-slim-bullseye
  --platform PLATFORM    Optional docker pull platform, for example linux/amd64.
  -h, --help             Show this help.

Examples:
  thirdparty/python/scripts/mirror_python_image.sh

  thirdparty/python/scripts/mirror_python_image.sh \
    --source-image python:3.8-slim-bullseye \
    --target-image 192.168.30.202:23099/thirdparty/python:3.8-slim-bullseye
EOF
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --source-image)
      source_image="${2:?missing value for --source-image}"
      shift 2
      ;;
    --target-image)
      target_image="${2:?missing value for --target-image}"
      shift 2
      ;;
    --platform)
      platform="${2:?missing value for --platform}"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

pull_args=()
if [ -n "${platform}" ]; then
  pull_args+=(--platform "${platform}")
fi

echo "Pulling ${source_image}"
docker pull "${pull_args[@]}" "${source_image}"

echo "Tagging ${source_image} as ${target_image}"
docker tag "${source_image}" "${target_image}"

echo "Pushing ${target_image}"
docker push "${target_image}"

echo "Mirrored ${source_image} -> ${target_image}"
