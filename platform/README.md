# Platform images

Run from the repository root. Build and publication are separate operations;
see the [root catalog](../README.md) for all image mappings.

```bash
make runtime-build REGISTRY=192.168.30.202:23099
make build-build REGISTRY=192.168.30.202:23099
```

`build-build` passes `RUNTIME_TAG=$(BASE_TAG)` to the Dockerfile, not `TAG_BASE`.
Override `BASE_TAG` consistently when building both layers.

## Image Layers

`platform/mono-runtime` is an independent Ubuntu/Mono baseline. It does not
inherit the Python/R stack. See [Mono build and acceptance](mono-runtime/README.md).

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
