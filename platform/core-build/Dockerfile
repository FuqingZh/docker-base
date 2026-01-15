# platform/core-build/Dockerfile
# syntax=docker/dockerfile:1.7

ARG REGISTRY=192.168.30.202:23099
ARG BASE_TAG=ubuntu24.04-py3.14-r4.5-20260113.01
FROM ${REGISTRY}/platform/core-runtime:${BASE_TAG}

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# ---- build args ----
ARG http_proxy
ARG https_proxy
ARG no_proxy

ARG BUILD_ID=dev
ARG VCS_REF=unknown
ARG BUILD_DATE=unknown

# ---- common env ----
ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    TZ=Etc/UTC \
    PYTHONIOENCODING=utf-8 \
    http_proxy=${http_proxy} \
    https_proxy=${https_proxy} \
    no_proxy=${no_proxy}

# ---- (A) System toolchain & build essentials (apt, not conda) ----
# 原则：编译链统一走 /usr/bin，避免 conda-forge toolchain ISA/CRT 兼容性问题
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential gfortran \
    pkg-config cmake make \
    git curl ca-certificates \
    # 常用构建辅助（configure / Makevars / diagnose）
    file binutils \
    # 常见 R 包编译依赖（按需增减；这些是“开发头文件”，不建议放 core-runtime）
    libcurl4-openssl-dev libssl-dev \
    libxml2-dev zlib1g-dev \
    libfontconfig1-dev libfreetype6-dev \
    libharfbuzz-dev libfribidi-dev \
    libpng-dev \
    # 图形/字体相关常见依赖（按需；ragg/systemfonts/textshaping 常见）
    libcairo2-dev \
    && ln -snf /usr/share/zoneinfo/${TZ} /etc/localtime \
    && echo "${TZ}" > /etc/timezone \
    && rm -rf /var/lib/apt/lists/*

# ---- (B) Force build to use system compilers (avoid conda wrappers) ----
# 关键：让 R CMD config / Makeconf 在编译时优先用 /usr/bin
ENV CC=/usr/bin/gcc \
    CXX=/usr/bin/g++ \
    FC=/usr/bin/gfortran \
    AR=/usr/bin/ar \
    RANLIB=/usr/bin/ranlib \
    STRIP=/usr/bin/strip

# ---- (C) renv global defaults (Renviron.site) ----
# 说明：
# - 统一 cache/library root，便于复用与审计
# - 允许非 root 用户写（后面 chown）
ENV RENV_PATHS_CACHE=/opt/renv/cache \
    RENV_PATHS_LIBRARY_ROOT=/opt/renv/library \
    RENV_CONFIG_REPOS_OVERRIDE=https://cloud.r-project.org \
    RENV_CONFIG_USE_CACHE=TRUE \
    RENV_CONFIG_CACHE_SYMLINKS=TRUE

RUN set -eux; \
    install -d -m 0775 /opt/renv/cache /opt/renv/library; \
    # 直接使用 vanilla 模式获取路径，避免反斜杠转义带来的混乱
    R_ETC=$(micromamba run -n runtime Rscript -e 'cat(R.home("etc"))'); \
    echo "R_ETC=${R_ETC}"; \
    cat > "${R_ETC}/Renviron.site" <<'EOF'
## ---- Global renv defaults (baked into image) ----
RENV_PATHS_CACHE=/opt/renv/cache
RENV_PATHS_LIBRARY_ROOT=/opt/renv/library
RENV_CONFIG_REPOS_OVERRIDE=https://cloud.r-project.org
RENV_CONFIG_USE_CACHE=TRUE
RENV_CONFIG_CACHE_SYMLINKS=TRUE
EOF

# ---- (D) Install only dependency managers (not project deps) ----
# 原则：core-build 只提供“恢复工具”，具体业务包交给各项目 lockfile/yaml
RUN micromamba run -n runtime python -m pip install -U pip \
    && micromamba run -n runtime python -m pip install -U pdm \
    && micromamba run -n runtime R -q -e 'install.packages("renv", repos="https://cloud.r-project.org")'

# ---- (F) Non-root user support (writable renv dirs) ----
# 默认就可写
ARG APP_UID=1000
ARG APP_GID=1000
ARG APP_USER=app

RUN set -eux; \
    groupadd -g "${APP_GID}" "${APP_USER}" || true; \
    useradd -m -u "${APP_UID}" -g "${APP_GID}" -s /bin/bash "${APP_USER}" || true; \
    # 让非 root 能写 renv cache/library（以及 mamba pkgs cache）
    chown -R "${APP_UID}:${APP_GID}" /opt/renv; \
    chmod -R g+rwX /opt/renv

# （可选）如果你希望非 root 也能创建/修改 conda env，则需要：
# - 把 /opt/mamba 也开放写权限（不建议在 core-build 默认这么做，安全与可复现性更差）
# RUN chown -R "${APP_UID}:${APP_GID}" /opt/mamba && chmod -R g+rwX /opt/mamba

# ---- (G) sanity checks ----
RUN set -eux; \
    micromamba run -n runtime R -q -e 'cat("R_HOME=", R.home(), "\n"); cat("R_ETC=", R.home("etc"), "\n")'; \
    which gcc; gcc --version | head -n 1; \
    which pkg-config; pkg-config --version; \
    micromamba run -n runtime R -q -e 'cat("CC=", Sys.getenv("CC"), "\n");'

LABEL org.opencontainers.image.title="platform/core-build" \
    org.opencontainers.image.description="Build base: core-runtime + apt toolchain + renv/pdm + renv global config" \
    org.opencontainers.image.vendor="internal" \
    org.opencontainers.image.version="${BUILD_ID}" \
    org.opencontainers.image.revision="${VCS_REF}" \
    org.opencontainers.image.created="${BUILD_DATE}"

CMD ["bash"]
