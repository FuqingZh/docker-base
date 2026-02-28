
ARG REGISTRY=ghcr.io/fuqingzh
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
    printf '%s\n' \
      'Acquire::Retries "5";' \
      'Acquire::http::Timeout "30";' \
      'Acquire::https::Timeout "30";' \
      > /etc/apt/apt.conf.d/80-retries; \
    rm -rf /var/lib/apt/lists/*; \
    for n_try in 1 2 3; do \
      apt-get update && \
      apt-get install -y --no-install-recommends --fix-missing \
      vim \
      ca-certificates curl tzdata bash tar bzip2 \
      libstdc++6 libgcc-s1 libssl3 libcurl4 libxml2 zlib1g \
      libfontconfig1 libfreetype6 \
      r-base \
      && break; \
      echo "apt install failed (attempt ${n_try}), retrying..."; \
      if [ "${n_try}" -eq 3 ]; then \
        exit 1; \
      fi; \
      sleep "$((n_try * 10))"; \
      rm -rf /var/lib/apt/lists/*; \
    done; \
    ln -snf "/usr/share/zoneinfo/${TZ}" /etc/localtime; \
    echo "${TZ}" > /etc/timezone; \
    rm -rf /var/lib/apt/lists/*


# Python tool (choose one standard)
RUN python -m pip install --no-cache-dir pdm uv

# R tool
RUN R -q -e 'install.packages("renv", repos="https://cloud.r-project.org"); packageVersion("renv")'


RUN install -d -m 1777 /work /opt/cache
WORKDIR /work

COPY scripts/dump_manifest.sh /usr/local/bin/dump_manifest.sh
RUN set -eux; chmod +x /usr/local/bin/dump_manifest.sh; /usr/local/bin/dump_manifest.sh > /opt/runtime_manifest.txt

CMD ["bash"]

LABEL org.opencontainers.image.description="Core runtime image, including Python and R environments with common dependencies." \
    org.opencontainers.image.licenses="MIT"