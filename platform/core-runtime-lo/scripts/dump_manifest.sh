#!/usr/bin/env bash
set -euo pipefail

echo "=== base manifest ==="
if [[ -f /opt/runtime_manifest.txt ]]; then
  cat /opt/runtime_manifest.txt
fi
echo

echo "=== libreoffice ==="
libreoffice --version || true
echo

echo "=== python uno ==="
/usr/bin/python3 - <<'PY' || true
import uno
from com.sun.star.beans import PropertyValue

print("uno import ok")
print(PropertyValue)
PY
echo

echo "=== libreoffice packages ==="
dpkg-query -W -f='${Package}=${Version}\n' 'libreoffice*' 'libuno*' 'uno-libs-private' 'ure*' 'python3-uno' 2>/dev/null | sort || true
echo

echo "=== current runtime key packages ==="
dpkg-query -W -f='${Package}=${Version}\n' \
  curl \
  libcurl3t64-gnutls \
  libcurl4t64 \
  libreoffice-writer \
  python3-uno \
  2>/dev/null | sort || true
