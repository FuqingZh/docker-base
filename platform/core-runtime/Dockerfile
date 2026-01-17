ARG REGISTRY=192.168.30.202:23099
ARG BASE_TAG=3.14
FROM ${REGISTRY}/thirdparty/python:${BASE_TAG}

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ARG http_proxy
ARG https_proxy
ARG no_proxy

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    TZ=Etc/UTC \
    PYTHONIOENCODING=utf-8 \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PIP_NO_CACHE_DIR=1

RUN --mount=type=cache,target=/var/cache/apt \
    set -eux; \
    export http_proxy="${http_proxy:-}" https_proxy="${https_proxy:-}" no_proxy="${no_proxy:-}"; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
    ca-certificates curl tzdata bash tar bzip2 \
    libstdc++6 libgcc-s1 libssl3 libcurl4 libxml2 zlib1g \
    libfontconfig1 libfreetype6 \
    r-base \
    ; \
    ln -snf "/usr/share/zoneinfo/${TZ}" /etc/localtime; \
    echo "${TZ}" > /etc/timezone; \
    rm -rf /var/lib/apt/lists/*

RUN install -d -m 1777 /work /opt/cache
WORKDIR /work

COPY scripts/dump_manifest.sh /usr/local/bin/dump_manifest.sh
RUN set -eux; chmod +x /usr/local/bin/dump_manifest.sh; /usr/local/bin/dump_manifest.sh > /opt/runtime_manifest.txt

CMD ["bash"]
