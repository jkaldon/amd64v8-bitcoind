#!/bin/sh

helm upgrade bitcoind -n bitcoin --create-namespace --install ./ -f values.yaml
