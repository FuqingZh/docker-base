# platform/core-build/Dockerfile
# syntax=docker/dockerfile:1.7

ARG REGISTRY=192.168.30.202:23099
ARG RUNTIME_TAG=debian-py3.14-r4.5-20260115.01   # 或你实际 runtime tag
FROM ${REGISTRY}/platform/core-runtime:${RUNTIME_TAG}

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ARG http_proxy
ARG https_proxy
ARG no_proxy

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    TZ=Etc/UTC

RUN --mount=type=cache,target=/var/cache/apt \
    set -eux; \
    export http_proxy="${http_proxy:-}" https_proxy="${https_proxy:-}" no_proxy="${no_proxy:-}"; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
    # 基础构建链
    build-essential make cmake pkg-config \
    git \
    # R 编译（若会编译 R 包）
    r-base-dev \
    # 常见 R/Python native 依赖
    libcurl4-openssl-dev libssl-dev libxml2-dev zlib1g-dev \
    libfontconfig1-dev libfreetype6-dev \
    libharfbuzz-dev libfribidi-dev \
    # Python native wheels（若需要）
    python3-dev \
    ; \
    rm -rf /var/lib/apt/lists/*


# Python tool (choose one standard)
RUN python -m pip install --no-cache-dir pdm uv

# R tool
RUN R -q -e 'install.packages("renv", repos="https://cloud.r-project.org"); packageVersion("renv")'

# 只做构建用，不需要 CMD
