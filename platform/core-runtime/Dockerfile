# platform/core-runtime/Dockerfile
# syntax=docker/dockerfile:1.7

ARG REGISTRY=192.168.30.202:23099
ARG BASE_TAG=3.14
FROM ${REGISTRY}/thirdparty/python:${BASE_TAG}

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# ---------------------------------------------------------------------------
# Build-time args (do NOT bake into image)
# ---------------------------------------------------------------------------
ARG http_proxy
ARG https_proxy
ARG no_proxy

# ---------------------------------------------------------------------------
# Base env
# ---------------------------------------------------------------------------
ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    TZ=Etc/UTC \
    PYTHONIOENCODING=utf-8 \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PIP_NO_CACHE_DIR=1

# ---------------------------------------------------------------------------
# Reproducible APT via Debian snapshot
#   - pins package versions at a specific timestamp
#   - avoids "latest repo" drift
# Notes:
#   - snapshot timestamps are UTC, e.g. 20260113T000000Z
#   - if you need a newer set of packages, bump the snapshot timestamp
# ---------------------------------------------------------------------------
ARG DEBIAN_SNAPSHOT="20260113T000000Z"
ARG DEBIAN_CODENAME="bookworm"

# ---------------------------------------------------------------------------
# OS runtime libs (keep minimal; no toolchain)
#   - add only what you want available at runtime
#   - R is installed via Debian repo (pinned to snapshot above)
# ---------------------------------------------------------------------------
RUN --mount=type=cache,target=/var/cache/apt \
    --mount=type=cache,target=/var/lib/apt \
    set -eux; \
    export http_proxy="${http_proxy}" https_proxy="${https_proxy}" no_proxy="${no_proxy}"; \
        printf 'Acquire::Check-Valid-Until "false";\nAcquire::Retries "3";\n' > /etc/apt/apt.conf.d/99snapshot; \
        printf '%s\n' \
            "deb http://snapshot.debian.org/archive/debian/${DEBIAN_SNAPSHOT} ${DEBIAN_CODENAME} main" \
            "deb http://snapshot.debian.org/archive/debian/${DEBIAN_SNAPSHOT} ${DEBIAN_CODENAME}-updates main" \
            "deb http://snapshot.debian.org/archive/debian-security/${DEBIAN_SNAPSHOT} ${DEBIAN_CODENAME}-security main" \
            > /etc/apt/sources.list; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    tzdata \
    bash \
    tar \
    bzip2 \
    # common runtime libs
    libstdc++6 \
    libgcc-s1 \
    libssl3 \
    libcurl4 \
    libxml2 \
    zlib1g \
    libfontconfig1 \
    libfreetype6 \
    # r
    r-base \
    ; \
    ln -snf "/usr/share/zoneinfo/${TZ}" /etc/localtime; \
    echo "${TZ}" > /etc/timezone; \
    rm -rf /var/lib/apt/lists/*

# ---------------------------------------------------------------------------
# Non-root friendliness:
#   - allow running the container with arbitrary uid/gid (e.g. docker --user)
#   - avoid baking a specific user into the image
# ---------------------------------------------------------------------------
RUN install -d -m 1777 /work /opt/cache

WORKDIR /work

# ---------------------------------------------------------------------------
# (6) Evidence: manifest + explicit env export
# ---------------------------------------------------------------------------
LABEL org.opencontainers.image.title="platform/core-runtime" \
    org.opencontainers.image.description="Python/R and common runtime libs" \
    org.opencontainers.image.vendor="internal" \
    org.opencontainers.image.licenses="Proprietary"

COPY scripts/dump_manifest.sh /usr/local/bin/dump_manifest.sh
RUN set -eux; \
    chmod +x /usr/local/bin/dump_manifest.sh; \
    /usr/local/bin/dump_manifest.sh > /opt/runtime_manifest.txt

CMD ["bash"]
