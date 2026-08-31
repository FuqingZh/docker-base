.DEFAULT_GOAL := help

REGISTRY ?= ghcr.io/fuqingzh
BASE_TAG ?= debian-py3.14-r4.5-20260228.0951
PY_BASE_TAG ?= 3.14
LO_BASE_TAG ?= $(BASE_TAG)
LO_TAG ?= debian-py3.14-r4.5-lo25.2-20260529
LO_DEBS_CONTEXT ?= /home/fqzhang/tmp/libreoffice-debs
TA_CLI_BASE_TAG ?= $(LO_TAG)
TA_CLI_TAG ?= debian-py3.14-r4.5-lo25.2-20260529
TA_CLI_ENV_CONTEXT ?= /home/fqzhang/micromamba/envs/gwas-cli
SIGNALP6_BASE_IMAGE ?= python:3.8-slim-bullseye
SIGNALP6_TAG ?= 6.0h-py3.8-cpu-20260605
SIGNALP6_PACKAGE_CONTEXT ?= /home/fqzhang/pkgs
SIGNALP6_SOURCE ?= signalp-6.0h.fast.fixed.tar.gz
PYTHON38_SOURCE_IMAGE ?= python:3.8-slim-bullseye
PYTHON38_TARGET_TAG ?= 3.8-slim-bullseye
PLATFORMS ?= linux/amd64
NO_PROXY_BUILD ?= 1
MONO_BASE_IMAGE ?= 192.168.30.202:23099/thirdparty/ubuntu:24.04@sha256:9dc159af07be6f78d586ba6f3ab67fc8ff115a76710427d0699be30068671103
MONO_VERSION ?= 6.8.0.105+dfsg-3.6ubuntu2
MONO_BUILD_NETWORK ?= default
MONO_TAG ?= ubuntu24.04-mono6.8.0.105-20260831
MONO_IMAGE = $(REGISTRY)/platform/mono-runtime:$(MONO_TAG)
SMOKE_CPUS ?= 4
SMOKE_MEMORY ?= 2g

http_proxy ?= $(HTTP_PROXY)
https_proxy ?= $(HTTPS_PROXY)
no_proxy ?= $(NO_PROXY)

ifeq ($(NO_PROXY_BUILD),1)
PROXY_BUILD_ARGS := --build-arg http_proxy= --build-arg https_proxy= --build-arg no_proxy=
else
PROXY_BUILD_ARGS := --build-arg http_proxy=$(http_proxy) --build-arg https_proxy=$(https_proxy) --build-arg no_proxy=$(no_proxy)
endif

.PHONY: runtime-build runtime-lo-build trait-association-cli-build signalp6-build build-build runtime-push runtime-lo-push trait-association-cli-push signalp6-push build-push python38-slim-mirror runtime-buildx-push runtime-lo-buildx-push trait-association-cli-buildx-push signalp6-buildx-push build-buildx-push all-buildx-push promote-stable
.PHONY: help check mono-build mono-smoke mono-push

help:
	@printf '%s\n' 'make check: source checks (no Docker/network)' 'Local builds: runtime-build build-build runtime-lo-build trait-association-cli-build signalp6-build mono-build' 'Mono acceptance: mono-smoke (local image only)' 'Publication: *-push, *-buildx-push, python38-slim-mirror, promote-stable' 'REGISTRY defaults to ghcr.io/fuqingzh; set REGISTRY=192.168.30.202:23099 for Harbor.' 'See README.md for build contexts and required external inputs.'

check:
	bash scripts/check.sh

mono-build:
	docker build --platform $(PLATFORMS) --network=$(MONO_BUILD_NETWORK) \
	  --build-arg BASE_IMAGE=$(MONO_BASE_IMAGE) --build-arg MONO_VERSION=$(MONO_VERSION) \
	  $(PROXY_BUILD_ARGS) \
	  -t $(MONO_IMAGE) ./platform/mono-runtime

mono-smoke:
	docker run --rm --pull=never --network=none --cpus=$(SMOKE_CPUS) --memory=$(SMOKE_MEMORY) \
	  $(MONO_IMAGE) check-mono

mono-push:
	docker push $(MONO_IMAGE)

runtime-build:
	docker build \
	  --build-arg REGISTRY=$(REGISTRY) --build-arg BASE_TAG=$(PY_BASE_TAG) \
	  $(PROXY_BUILD_ARGS) \
	  -t $(REGISTRY)/platform/core-runtime:$(BASE_TAG) \
	  ./platform/core-runtime

runtime-lo-build:
	DOCKER_BUILDKIT=1 docker build \
	  --build-arg REGISTRY=$(REGISTRY) --build-arg RUNTIME_TAG=$(LO_BASE_TAG) \
	  --build-context lo_debs=$(LO_DEBS_CONTEXT) \
	  $(PROXY_BUILD_ARGS) \
	  -t $(REGISTRY)/platform/core-runtime:$(LO_TAG) \
	  -f ./platform/core-runtime-lo/Dockerfile \
	  .

trait-association-cli-build:
	DOCKER_BUILDKIT=1 docker build \
	  --build-arg REGISTRY=$(REGISTRY) --build-arg RUNTIME_TAG=$(TA_CLI_BASE_TAG) \
	  --build-context trait_association_cli_env=$(TA_CLI_ENV_CONTEXT) \
	  $(PROXY_BUILD_ARGS) \
	  -t $(REGISTRY)/platform/trait-association-cli:$(TA_CLI_TAG) \
	  -f ./platform/trait-association-cli/Dockerfile \
	  .

signalp6-build:
	DOCKER_BUILDKIT=1 docker build \
	  --build-arg BASE_IMAGE=$(SIGNALP6_BASE_IMAGE) \
	  --build-arg SIGNALP6_SOURCE=$(SIGNALP6_SOURCE) \
	  --build-context signalp6_package=$(SIGNALP6_PACKAGE_CONTEXT) \
	  $(PROXY_BUILD_ARGS) \
	  -t $(REGISTRY)/thirdparty/signalp6:$(SIGNALP6_TAG) \
	  -f ./thirdparty/signalp6/Dockerfile \
	  .

build-build:
	docker build \
	  --build-arg REGISTRY=$(REGISTRY) --build-arg RUNTIME_TAG=$(BASE_TAG) \
	  $(PROXY_BUILD_ARGS) \
	  -t $(REGISTRY)/platform/core-build:$(BASE_TAG) \
	  ./platform/core-build

runtime-push:
	docker push $(REGISTRY)/platform/core-runtime:$(BASE_TAG)

runtime-lo-push:
	docker push $(REGISTRY)/platform/core-runtime:$(LO_TAG)

trait-association-cli-push:
	docker push $(REGISTRY)/platform/trait-association-cli:$(TA_CLI_TAG)

signalp6-push:
	docker push $(REGISTRY)/thirdparty/signalp6:$(SIGNALP6_TAG)

build-push:
	docker push $(REGISTRY)/platform/core-build:$(BASE_TAG)

python38-slim-mirror:
	thirdparty/python/scripts/mirror_python_image.sh \
	  --source-image $(PYTHON38_SOURCE_IMAGE) \
	  --target-image $(REGISTRY)/thirdparty/python:$(PYTHON38_TARGET_TAG)

runtime-buildx-push:
	docker buildx build \
	  --platform $(PLATFORMS) \
	  --build-arg REGISTRY=$(REGISTRY) --build-arg BASE_TAG=$(PY_BASE_TAG) \
	  $(PROXY_BUILD_ARGS) \
	  -t $(REGISTRY)/platform/core-runtime:$(BASE_TAG) \
	  --push \
	  ./platform/core-runtime

runtime-lo-buildx-push:
	docker buildx build \
	  --platform $(PLATFORMS) \
	  --build-arg REGISTRY=$(REGISTRY) --build-arg RUNTIME_TAG=$(LO_BASE_TAG) \
	  --build-context lo_debs=$(LO_DEBS_CONTEXT) \
	  $(PROXY_BUILD_ARGS) \
	  -t $(REGISTRY)/platform/core-runtime:$(LO_TAG) \
	  -f ./platform/core-runtime-lo/Dockerfile \
	  --push \
	  .

trait-association-cli-buildx-push:
	docker buildx build \
	  --platform $(PLATFORMS) \
	  --build-arg REGISTRY=$(REGISTRY) --build-arg RUNTIME_TAG=$(TA_CLI_BASE_TAG) \
	  --build-context trait_association_cli_env=$(TA_CLI_ENV_CONTEXT) \
	  $(PROXY_BUILD_ARGS) \
	  -t $(REGISTRY)/platform/trait-association-cli:$(TA_CLI_TAG) \
	  -f ./platform/trait-association-cli/Dockerfile \
	  --push \
	  .

signalp6-buildx-push:
	docker buildx build \
	  --platform $(PLATFORMS) \
	  --build-arg BASE_IMAGE=$(SIGNALP6_BASE_IMAGE) \
	  --build-arg SIGNALP6_SOURCE=$(SIGNALP6_SOURCE) \
	  --build-context signalp6_package=$(SIGNALP6_PACKAGE_CONTEXT) \
	  $(PROXY_BUILD_ARGS) \
	  -t $(REGISTRY)/thirdparty/signalp6:$(SIGNALP6_TAG) \
	  -f ./thirdparty/signalp6/Dockerfile \
	  --push \
	  .

build-buildx-push:
	docker buildx build \
	  --platform $(PLATFORMS) \
	  --build-arg REGISTRY=$(REGISTRY) --build-arg RUNTIME_TAG=$(BASE_TAG) \
	  $(PROXY_BUILD_ARGS) \
	  -t $(REGISTRY)/platform/core-build:$(BASE_TAG) \
	  --push \
	  ./platform/core-build

all-buildx-push: runtime-buildx-push build-buildx-push

promote-stable:
	docker pull $(REGISTRY)/platform/core-runtime:$(BASE_TAG)
	docker tag  $(REGISTRY)/platform/core-runtime:$(BASE_TAG) $(REGISTRY)/platform/core-runtime:stable
	docker push $(REGISTRY)/platform/core-runtime:stable
	docker pull $(REGISTRY)/platform/core-build:$(BASE_TAG)
	docker tag  $(REGISTRY)/platform/core-build:$(BASE_TAG) $(REGISTRY)/platform/core-build:stable
	docker push $(REGISTRY)/platform/core-build:stable
