ARG BASE_IMAGE=192.168.30.202:23099/thirdparty/ubuntu:24.04@sha256:9dc159af07be6f78d586ba6f3ab67fc8ff115a76710427d0699be30068671103
FROM ${BASE_IMAGE}

ARG BASE_IMAGE
ARG MONO_VERSION=6.8.0.105+dfsg-3.6ubuntu2
LABEL org.opencontainers.image.title="mono-runtime" \
      org.opencontainers.image.description="Ubuntu Mono runtime and complete framework assemblies; no application binaries" \
      org.opencontainers.image.base.name="${BASE_IMAGE}" \
      org.opencontainers.image.version="${MONO_VERSION}"

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
RUN apt-get -o APT::Update::Error-Mode=any -o Acquire::Retries=2 -o Acquire::http::Timeout=30 update \
    && DEBIAN_FRONTEND=noninteractive apt-get -o Acquire::Retries=2 -o Acquire::http::Timeout=30 \
       install -y --no-install-recommends "mono-complete=${MONO_VERSION}" ca-certificates \
    && rm -rf /var/lib/apt/lists/*

COPY smoke.cs /opt/mono-runtime/smoke.cs
COPY scripts/check-mono.sh /usr/local/bin/check-mono
RUN chmod 0755 /usr/local/bin/check-mono \
    && mcs -r:System.Data -out:/opt/mono-runtime/smoke.exe /opt/mono-runtime/smoke.cs \
    && check-mono \
    && dpkg-query -W -f='${Package}\t${Version}\t${Architecture}\n' > /opt/mono-runtime/packages.tsv \
    && printf '%s\n' "base_image=${BASE_IMAGE}" "mono_package=${MONO_VERSION}" > /opt/mono-runtime/build-info.txt

WORKDIR /work
CMD ["mono", "--version"]
