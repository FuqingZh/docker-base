# Core Runtime LibreOffice Variant

This image extends `platform/core-runtime` with LibreOffice Writer and Python
UNO. It is intended for report rendering workloads that need DOCX to PDF
conversion at runtime.

The LibreOffice deb bundle is supplied as a Docker BuildKit named build context
instead of being committed to this repository.

Example:

```bash
DOCKER_BUILDKIT=1 docker build \
  --build-arg REGISTRY=192.168.30.202:23099 \
  --build-arg RUNTIME_TAG=debian-py3.14-r4.5-20260228.0951 \
  --build-context lo_debs=/home/fqzhang/tmp/libreoffice-debs \
  -t 192.168.30.202:23099/platform/core-runtime:debian-py3.14-r4.5-lo25.2-20260529 \
  -f platform/core-runtime-lo/Dockerfile \
  .
```

Required runtime checks:

```bash
/usr/bin/python3 -c "import uno; from com.sun.star.beans import PropertyValue"
command -v libreoffice
libreoffice --version
```
