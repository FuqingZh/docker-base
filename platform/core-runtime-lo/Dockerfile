# platform/core-runtime-lo/Dockerfile

ARG REGISTRY=ghcr.io/fuqingzh
ARG RUNTIME_TAG=debian-py3.14-r4.5-20260228.0951
FROM ${REGISTRY}/platform/core-runtime:${RUNTIME_TAG}

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    TZ=Etc/UTC

# Install LibreOffice Writer + UNO from a named build context:
#   docker build \
#     --build-context lo_debs=/path/to/libreoffice-debs \
#     -f platform/core-runtime-lo/Dockerfile .
#
# Keep the deb bundle outside git. It is a platform release artifact rather than
# source code.
COPY --from=lo_debs / /tmp/libreoffice-debs/

RUN set -eux; \
    find /tmp/libreoffice-debs -maxdepth 1 -name '*ubuntu*' -print -delete; \
    dpkg -i /tmp/libreoffice-debs/*.deb || true; \
    apt-get -y --no-download -f install; \
    dpkg -i /tmp/libreoffice-debs/libreoffice-writer_*.deb; \
    /usr/bin/python3 -c "import uno; from com.sun.star.beans import PropertyValue"; \
    command -v libreoffice; \
    libreoffice --version; \
    rm -rf /tmp/libreoffice-debs /var/lib/apt/lists/*

COPY platform/core-runtime-lo/scripts/dump_manifest.sh /usr/local/bin/dump_manifest-lo.sh
RUN set -eux; chmod +x /usr/local/bin/dump_manifest-lo.sh; /usr/local/bin/dump_manifest-lo.sh > /opt/runtime_lo_manifest.txt

CMD ["bash"]

LABEL org.opencontainers.image.description="Core runtime image with LibreOffice Writer and Python UNO for report PDF export." \
    org.opencontainers.image.licenses="MIT"
