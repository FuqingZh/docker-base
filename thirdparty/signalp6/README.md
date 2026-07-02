# SignalP 6 Runtime

`thirdparty/signalp6` packages the standalone SignalP 6 CLI in an isolated
Python environment managed by `uv`. The image is intended to be called as its
own workflow task, not copied into general Proteomics runtime images.

The SignalP package and model weights are external build inputs. Keep them out
of this repository and pass them through the BuildKit `signalp6_package` named
context. The context can be either an unpacked package directory, or a directory
that contains the tarball named by `SIGNALP6_SOURCE`.

## Build

```bash
make signalp6-build \
  REGISTRY=192.168.30.202:23099 \
  SIGNALP6_BASE_IMAGE=python:3.8-slim-bullseye \
  SIGNALP6_TAG=6.0h-py3.8-cpu-20260605 \
  SIGNALP6_PACKAGE_CONTEXT=/home/fqzhang/pkgs \
  SIGNALP6_SOURCE=signalp-6.0h.fast.fixed.tar.gz
```

For an already unpacked package directory, point `SIGNALP6_PACKAGE_CONTEXT` at
that directory and set `SIGNALP6_SOURCE=.`.

For stable internal builds, mirror the Python 3.8 base image into Harbor first
and override `SIGNALP6_BASE_IMAGE`, for example:

```bash
make python38-slim-mirror REGISTRY=192.168.30.202:23099

make signalp6-build \
  REGISTRY=192.168.30.202:23099 \
  SIGNALP6_BASE_IMAGE=192.168.30.202:23099/thirdparty/python:3.8-slim-bullseye
```

Push:

```bash
make signalp6-push \
  REGISTRY=192.168.30.202:23099 \
  SIGNALP6_TAG=6.0h-py3.8-cpu-20260605
```

## Smoke Test

```bash
docker run --rm \
  192.168.30.202:23099/thirdparty/signalp6:6.0h-py3.8-cpu-20260605 \
  signalp6 --help
```

For WDL usage, run FASTA preparation and XLSX export in the Proteomics image,
and run only the SignalP prediction step in this image.
