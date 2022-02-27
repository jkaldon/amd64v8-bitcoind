#!/bin/sh
set -ex
DOCKER_TAG=22.0.0-12

docker build --progress plain -t "jkaldon/arm64v8-bitcoind:${DOCKER_TAG}" .
docker push "jkaldon/arm64v8-bitcoind:${DOCKER_TAG}"
