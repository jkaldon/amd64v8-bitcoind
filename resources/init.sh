#!/bin/sh

if [ -d /data/bitcoin ]; then
  echo 'Found existing directory at /data/bitcoin.  Skipping initialization.'
  exit 0
fi

echo 'Initializing bitcoin configuration with RPC username and password...'

mkdir -p /data/bitcoin
echo "Created /data/bitcoind directory."

RPCAUTH_OUT=$(python3 /home/bitcoin/rpcauth.py "${RPC_USERNAME}" "${RPC_PASSWORD}" 2>/tmp/rpcauth.err | grep 'rpcauth=')

RPCAUTH_ERR=$(cat /tmp/rpcauth.err)
if [ -n "${RPCAUTH_ERR}" ]; then
  echo 'Unexpected error while initializing RPC authentication:'
  echo "${RPCAUTH_ERR}"
  echo '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
  exit 129
fi

sed -E "s/^rpcauth=.*$/${RPCAUTH_OUT}/" /home/bitcoin/bitcoin.conf.template > /data/bitcoin/bitcoin.conf
echo "Added '${RPCAUTH_OUT}' to /data/bitcoin/bitcoin.conf."

echo 'Finished!'
