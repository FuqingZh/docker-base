```bash
TAG_IMMUTABLE=ubuntu24.04-py3.14-r4.5-20260115.01

# core-runtime
cd project/docker-base/platform/core-runtime

docker build \
  -t 192.168.30.202:23099/platform/core-runtime:${TAG_IMMUTABLE} \
  .

docker push 192.168.30.202:23099/platform/core-runtime:${TAG_IMMUTABLE}

# core-build
cd project/docker-base/platform/core-build
TAG_IMMUTABLE_BUILD=ubuntu24.04-py3.14-r4.5-20260115.01
docker build \
  --build-arg TAG_BASE=${TAG_IMMUTABLE_BUILD} \
  -t 192.168.30.202:23099/platform/core-build:${TAG_IMMUTABLE_BUILD} \
  .
docker push 192.168.30.202:23099/platform/core-build:${TAG_IMMUTABLE_BUILD}


```


