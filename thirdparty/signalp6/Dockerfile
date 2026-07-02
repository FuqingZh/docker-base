# thirdparty/signalp6/Dockerfile
# syntax=docker/dockerfile:1.7

ARG BASE_IMAGE=python:3.8-slim-bullseye
FROM ${BASE_IMAGE}

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ARG http_proxy
ARG https_proxy
ARG no_proxy
ARG SIGNALP6_SOURCE=signalp-6.0h.fast.fixed.tar.gz
ARG TORCH_VERSION=1.13.1+cpu
ARG TORCH_INDEX_URL=https://download.pytorch.org/whl/cpu

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    TZ=Etc/UTC \
    PYTHONIOENCODING=utf-8 \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    UV_NO_CACHE=1 \
    UV_PYTHON_DOWNLOADS=never \
    SIGNALP6_HOME=/opt/signalp6 \
    VIRTUAL_ENV=/opt/signalp6/venv \
    PATH=/opt/signalp6/venv/bin:${PATH}

RUN --mount=type=cache,target=/var/cache/apt \
    set -eux; \
    export http_proxy="${http_proxy:-}" https_proxy="${https_proxy:-}" no_proxy="${no_proxy:-}"; \
    printf '%s\n' \
      'Acquire::Retries "5";' \
      'Acquire::http::Timeout "30";' \
      'Acquire::https::Timeout "30";' \
      > /etc/apt/apt.conf.d/80-retries; \
    for n_try in 1 2 3; do \
      apt-get update && \
      apt-get install -y --no-install-recommends --fix-missing \
        bash \
        ca-certificates \
        curl \
        libfreetype6 \
        libgomp1 \
        libstdc++6 \
        procps \
        tar \
        tzdata \
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

RUN set -eux; \
    install -d -m 0755 "${SIGNALP6_HOME}" /work

COPY --from=signalp6_package ${SIGNALP6_SOURCE} "${SIGNALP6_HOME}/package-input/"

RUN set -eux; \
    archive="$(find "${SIGNALP6_HOME}/package-input" -maxdepth 1 -type f \( -name '*.tar.gz' -o -name '*.tgz' \) | head -n 1)"; \
    if [ -n "${archive}" ]; then \
      mkdir -p "${SIGNALP6_HOME}/package-extract"; \
      tar -xzf "${archive}" -C "${SIGNALP6_HOME}/package-extract"; \
      search_root="${SIGNALP6_HOME}/package-extract"; \
    else \
      search_root="${SIGNALP6_HOME}/package-input"; \
    fi; \
    python -m pip install --no-cache-dir uv; \
    uv venv "${VIRTUAL_ENV}"; \
    uv pip install --python "${VIRTUAL_ENV}/bin/python" "pip<25" setuptools wheel; \
    uv pip install --python "${VIRTUAL_ENV}/bin/python" \
      --index-url "${TORCH_INDEX_URL}" \
      "torch==${TORCH_VERSION}"; \
    uv pip install --python "${VIRTUAL_ENV}/bin/python" \
      numpy \
      matplotlib \
      tqdm; \
    package_dir=""; \
    if [ -f "${search_root}/pyproject.toml" ]; then \
      package_dir="${search_root}"; \
    else \
      package_dir="$(find "${search_root}" -mindepth 1 -maxdepth 4 -type f -name pyproject.toml -printf '%h\n' | head -n 1)"; \
    fi; \
    test -n "${package_dir}"; \
    uv pip install --python "${VIRTUAL_ENV}/bin/python" --no-deps "${package_dir}"; \
    signalp6 --help >/tmp/signalp6.help 2>&1 || test -s /tmp/signalp6.help; \
    signalp6 --version >/tmp/signalp6.version 2>&1 || true; \
    python - <<'PY' > /opt/signalp6/manifest.txt
import importlib.metadata
import pathlib
import platform

print(f"python={platform.python_version()}")
for package in ["signalp6", "torch", "numpy", "matplotlib", "tqdm"]:
    try:
        print(f"{package}={importlib.metadata.version(package)}")
    except importlib.metadata.PackageNotFoundError:
        print(f"{package}=missing")
weights = pathlib.Path("/opt/signalp6/venv/lib").glob(
    "python*/site-packages/signalp/model_weights/distilled_model_signalp6.pt"
)
print(f"model_weights={'present' if any(weights) else 'missing'}")
PY

WORKDIR /work
CMD ["signalp6", "--help"]

LABEL org.opencontainers.image.description="Third-party SignalP 6 runtime with an isolated Python environment." \
    org.opencontainers.image.licenses="third-party"
