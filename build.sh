#!/bin/sh
set -ex
DOCKER_TAG=23.0.0-1

docker build --progress plain -t "jkaldon/arm64v8-bitcoind:${DOCKER_TAG}" .
docker push "jkaldon/arm64v8-bitcoind:${DOCKER_TAG}"
