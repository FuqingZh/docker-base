```bash
TAG_IMMUTABLE=debian-py3.14-r4.5-20260115.01

# core-runtime
cd project/docker-base/platform/core-runtime

docker build \
  -t 192.168.30.202:23099/platform/core-runtime:${TAG_IMMUTABLE} \
  .

docker push 192.168.30.202:23099/platform/core-runtime:${TAG_IMMUTABLE}

# core-build
cd project/docker-base/platform/core-build
docker build \
  --build-arg TAG_BASE=${TAG_IMMUTABLE_BUILD} \
  -t 192.168.30.202:23099/platform/core-build:${TAG_IMMUTABLE_BUILD} \
  .
docker push 192.168.30.202:23099/platform/core-build:${TAG_IMMUTABLE_BUILD}


```

## Image Layers

`platform/core-runtime` is the default Python/R runtime baseline.

`platform/core-build` extends `platform/core-runtime` with compiler toolchains,
development headers, and build-time native dependencies.

`platform/core-runtime-lo` extends `platform/core-runtime` with LibreOffice
Writer and Python UNO for runtime report export, especially DOCX to PDF
conversion. This is a runtime capability, not a build capability.

`platform/trait-association-cli` extends `platform/core-runtime-lo` with the
runtime command-line toolchain required by the active trait association
workflow. The toolchain is exposed through `/opt/trait-association-cli/bin` and
does not require shell activation.

## LibreOffice Runtime Variant

Build with an external Debian trixie deb bundle:

```bash
make runtime-lo-build \
  REGISTRY=192.168.30.202:23099 \
  LO_BASE_TAG=debian-py3.14-r4.5-20260228.0951 \
  LO_TAG=debian-py3.14-r4.5-lo25.2-20260529 \
  LO_DEBS_CONTEXT=/home/fqzhang/tmp/libreoffice-debs
```

Push:

```bash
make runtime-lo-push \
  REGISTRY=192.168.30.202:23099 \
  LO_TAG=debian-py3.14-r4.5-lo25.2-20260529
```

The deb bundle should not be committed to this repository. The Docker build
uses it through BuildKit named context `lo_debs`.

## Trait Association CLI Runtime

Build with an external prebuilt micromamba environment:

```bash
make trait-association-cli-build \
  REGISTRY=192.168.30.202:23099 \
  TA_CLI_BASE_TAG=debian-py3.14-r4.5-lo25.2-20260529 \
  TA_CLI_TAG=debian-py3.14-r4.5-lo25.2-20260529 \
  TA_CLI_ENV_CONTEXT=/home/fqzhang/micromamba/envs/gwas-cli
```

Push:

```bash
make trait-association-cli-push \
  REGISTRY=192.168.30.202:23099 \
  TA_CLI_TAG=debian-py3.14-r4.5-lo25.2-20260529
```

The environment context should not be committed to this repository. It is a
large binary build input and should be replaced by a lock-driven micromamba
build when the toolchain package set is finalized.
