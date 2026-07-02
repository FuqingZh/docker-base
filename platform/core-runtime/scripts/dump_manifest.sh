#!/usr/bin/env bash
set -euo pipefail

echo "=== apt sources ==="
if compgen -G "/etc/apt/sources.list*" >/dev/null; then
	ls -la /etc/apt/sources.list* || true
	echo
	cat /etc/apt/sources.list || true
	echo
	find /etc/apt/sources.list.d -maxdepth 1 -type f -print -exec cat {} \; 2>/dev/null || true
fi
echo

echo "=== dpkg packages (name=version) ==="
dpkg-query -W -f='${Package}=${Version}\n' 2>/dev/null | sort || true
echo

echo "=== os-release ==="
cat /etc/os-release || true
echo

echo "=== glibc ==="
ldd --version | head -n 2 || true
echo

echo "=== openssl ==="
openssl version -a || true
echo

echo "=== python ==="
python -V
python -c "import sys; print(sys.version)"
echo

echo "=== R ==="
R --version | head -n 2 || true
echo
