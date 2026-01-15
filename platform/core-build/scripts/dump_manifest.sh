#!/usr/bin/env bash
set -euo pipefail

echo "=== os-release ==="
cat /etc/os-release || true
echo

echo "=== glibc (ldd) ==="
ldd --version | head -n 2 || true
echo

echo "=== openssl ==="
openssl version -a | sed -n '1,8p' || true
echo

echo "=== micromamba ==="
micromamba --version || true
echo

echo "=== python ==="
python -V || true
python -c "import sys; print(sys.version)" || true
echo

echo "=== R ==="
R --version | head -n 2 || true
echo

echo "=== PATH ==="
echo "$PATH"

echo "=== pdm ==="
pdm --version || true

echo "=== renv ==="
R -q -e 'packageVersion("renv")' || true
