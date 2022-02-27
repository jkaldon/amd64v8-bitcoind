FROM debian:buster-slim

# Image metadata
# git commit
LABEL org.opencontainers.image.revision="-"
LABEL org.opencontainers.image.source="https://github.com/jkaldon/arm64v8-bitcoind/tree/master"

ARG BITCOIN_CORE_BASE_URL=https://bitcoincore.org/bin/bitcoin-core-22.0/
ARG BITCOIN_CORE_ARCHIVE=bitcoin-22.0-aarch64-linux-gnu.tar.gz

RUN set -e && \
  apt-get update && \
  apt-get install -y \
          curl \
          wget \
          openssl \
          bash \
          vim \
          coreutils \
          python3 \
          gnupg && \
  cd /tmp && \
  wget -nv -O "${BITCOIN_CORE_ARCHIVE}" "${BITCOIN_CORE_BASE_URL}/${BITCOIN_CORE_ARCHIVE}" && \
  wget -nv -O SHA256SUMS                "${BITCOIN_CORE_BASE_URL}/SHA256SUMS" && \
  wget -nv -O SHA256SUMS.asc            "${BITCOIN_CORE_BASE_URL}/SHA256SUMS.asc" && \
  sha256sum --ignore-missing --check SHA256SUMS && \
  TAR_OUTPUT=$(tar -xvzf "${BITCOIN_CORE_ARCHIVE}") && \
  EXTRACTED_SUBDIR=$(echo $TAR_OUTPUT | head -n1 | cut -f1 -d\/ ) && \
  install -m 0755 -o root -g root -t /usr/local/bin ${EXTRACTED_SUBDIR}/bin/* && \
  rm -rf "${BITCOIN_CORE_ARCHIVE}" "SHA256SUMS" "SHA256SUMS.asc" "${EXTRACTED_SUBDIR}" && \
  useradd -d /home/bitcoin -m -s /usr/sbin/nologin bitcoin && \
  mkdir /data && \
  chown -R bitcoin.bitcoin /data

 # It would be much better to verify that SHA256SUMS has valid 
 # signatures from the developers, but gpg --verify is giving
 # me grief.  The following is roughly how it would be done.
 #
 # wget https://raw.githubusercontent.com/bitcoin/bitcoin/master/contrib/builder-keys/keys.txt
 # while read fingerprint keyholder_name; do i
 #   gpg --keyserver hkps://keyserver.ubuntu.com --recv-keys ${fingerprint}
 # done < ./keys.txt  
 # gpg --verify SHA256SUMS.asc
USER bitcoin

COPY resources/* /home/bitcoin/

RUN set -e && \
  ln -s /data/bitcoin /home/bitcoin/.bitcoin

CMD [ \
  "/usr/local/bin/bitcoind", \
  "-server", \
  "-pid=/home/bitcoin/bitcoind.pid", \
  "-conf=/home/bitcoin/.bitcoin/bitcoin.conf", \
  "-datadir=/home/bitcoin/.bitcoin", \
  "-startupnotify=/bin/chmod g+r /home/bitcoin/.bitcoin/.cookie" \
]
