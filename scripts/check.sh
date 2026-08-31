#!/usr/bin/env bash
# Source-only gate; no Docker daemon, downloads, or publication.
set -euo pipefail
cd "$(dirname "$0")/.."
while IFS= read -r -d '' script; do
    bash -n "$script"
done < <(find platform thirdparty scripts -maxdepth 5 -type f -name '*.sh' -print0)
PYTHONDONTWRITEBYTECODE=1 python3 -m unittest discover -s tests -v
