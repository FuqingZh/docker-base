REGISTRY ?= 192.168.30.202:23099
BASE_TAG ?= ubuntu24.04-py3.14-r4.5-20260113.01

runtime-build:
	docker build \
	  -t $(REGISTRY)/platform/core-runtime:$(BASE_TAG) \
	  ./platform/core-runtime

build-build:
	docker build \
	  --build-arg BASE_TAG=$(BASE_TAG) \
	  -t $(REGISTRY)/platform/core-build:$(BASE_TAG) \
	  ./platform/core-build

runtime-push:
	docker push $(REGISTRY)/platform/core-runtime:$(BASE_TAG)

build-push:
	docker push $(REGISTRY)/platform/core-build:$(BASE_TAG)

promote-stable:
	docker pull $(REGISTRY)/platform/core-runtime:$(BASE_TAG)
	docker tag  $(REGISTRY)/platform/core-runtime:$(BASE_TAG) $(REGISTRY)/platform/core-runtime:stable
	docker push $(REGISTRY)/platform/core-runtime:stable
	docker pull $(REGISTRY)/platform/core-build:$(BASE_TAG)
	docker tag  $(REGISTRY)/platform/core-build:$(BASE_TAG) $(REGISTRY)/platform/core-build:stable
	docker push $(REGISTRY)/platform/core-build:stable
