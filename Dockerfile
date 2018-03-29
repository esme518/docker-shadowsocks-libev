#
# Dockerfile for shadowsocks-libev
#

FROM alpine:3.7

ENV SS_VER 3.1.3
ENV SS_URL https://github.com/shadowsocks/shadowsocks-libev/releases/download/v$SS_VER/shadowsocks-libev-$SS_VER.tar.gz
ENV SS_DIR shadowsocks-libev-$SS_VER
ENV OBFS_URL https://github.com/shadowsocks/simple-obfs.git
ENV OBFS_DIR simple-obfs

RUN set -ex \
    && apk add --no-cache --virtual .run-deps \
        pcre \
        libev \
        c-ares \
        libsodium \
        mbedtls \
    && apk add --no-cache --virtual .build-deps \
        curl \
        autoconf \
        build-base \
        libtool \
        linux-headers \
        libressl-dev \
        zlib-dev \
        asciidoc \
        xmlto \
        pcre-dev \
        automake \
        mbedtls-dev \
        libsodium-dev \
        c-ares-dev \
        libev-dev \
        rng-tools \
    && curl -sSL $SS_URL | tar xz \
    && cd $SS_DIR \
    && ./configure \
    && make \
    && make install \
    && cd .. \
    && rm -rf $SS_DIR \
    && git clone $OBFS_URL \
    && cd $OBFS_DIR \
    && git submodule update --init --recursive \
    && ./autogen.sh \
    && ./configure \
    && make \
    && make install \
    && cd .. \
    && rm -rf $OBFS_DIR \
    && apk del .build-deps \
    && rm -rf /var/cache/apk

ENV SS_ADDR     0.0.0.0
ENV SS_PORT     8388
ENV SS_PASSWORD p@ssw0rd
ENV SS_METHOD   aes-256-cfb
ENV SS_TIMEOUT  300
ENV SS_PLUGIN   --plugin obfs-server --plugin-opts "obfs=http"

EXPOSE $SS_PORT/tcp
EXPOSE $SS_PORT/udp

CMD ss-server -s $SS_ADDR     \
              -p $SS_PORT     \
              -k $SS_PASSWORD \
              -m $SS_METHOD   \
              -t $SS_TIMEOUT  \
              -u $SS_PLUGIN
