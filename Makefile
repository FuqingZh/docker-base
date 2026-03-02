REGISTRY ?= ghcr.io/fuqingzh
BASE_TAG ?= debian-py3.14-r4.5-20260228.0951
PY_BASE_TAG ?= 3.14
PLATFORMS ?= linux/amd64
NO_PROXY_BUILD ?= 1

http_proxy ?= $(HTTP_PROXY)
https_proxy ?= $(HTTPS_PROXY)
no_proxy ?= $(NO_PROXY)

ifeq ($(NO_PROXY_BUILD),1)
PROXY_BUILD_ARGS := --build-arg http_proxy= --build-arg https_proxy= --build-arg no_proxy=
else
PROXY_BUILD_ARGS := --build-arg http_proxy=$(http_proxy) --build-arg https_proxy=$(https_proxy) --build-arg no_proxy=$(no_proxy)
endif

.PHONY: runtime-build build-build runtime-push build-push runtime-buildx-push build-buildx-push all-buildx-push promote-stable

runtime-build:
	docker build \
	  --build-arg REGISTRY=$(REGISTRY) --build-arg BASE_TAG=$(PY_BASE_TAG) \
	  $(PROXY_BUILD_ARGS) \
	  -t $(REGISTRY)/platform/core-runtime:$(BASE_TAG) \
	  ./platform/core-runtime

build-build:
	docker build \
	  --build-arg REGISTRY=$(REGISTRY) --build-arg RUNTIME_TAG=$(BASE_TAG) \
	  $(PROXY_BUILD_ARGS) \
	  -t $(REGISTRY)/platform/core-build:$(BASE_TAG) \
	  ./platform/core-build

runtime-push:
	docker push $(REGISTRY)/platform/core-runtime:$(BASE_TAG)

build-push:
	docker push $(REGISTRY)/platform/core-build:$(BASE_TAG)

runtime-buildx-push:
	docker buildx build \
	  --platform $(PLATFORMS) \
	  --build-arg REGISTRY=$(REGISTRY) --build-arg BASE_TAG=$(PY_BASE_TAG) \
	  $(PROXY_BUILD_ARGS) \
	  -t $(REGISTRY)/platform/core-runtime:$(BASE_TAG) \
	  --push \
	  ./platform/core-runtime

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
