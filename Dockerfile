#
# Dockerfile for shadowsocks-libev
#

FROM alpine:3.4

ENV SS_VER 2.6.0
ENV SS_URL https://github.com/shadowsocks/shadowsocks-libev/archive/v$SS_VER.tar.gz
ENV SS_DIR shadowsocks-libev-$SS_VER

RUN set -ex \
    && apk add --no-cache --virtual .run-deps \
        pcre \
    && apk add --no-cache --virtual .build-deps \
        curl \
        autoconf \
        build-base \
        libtool \
        linux-headers \
        openssl-dev \
        asciidoc \
        xmlto \
        pcre-dev \
    && curl -sSL $SS_URL | tar xz \
    && cd $SS_DIR \
    && ./configure \
    && make \
    && make install \
    && cd .. \
    && rm -rf $SS_DIR \
    && apk del .build-deps \
    && rm -rf /var/cache/apk

ENV SS_ADDR     0.0.0.0
ENV SS_PORT     8388
ENV SS_PASSWORD p@ssw0rd
ENV SS_METHOD   aes-256-cfb
ENV SS_TIMEOUT  300

EXPOSE $SS_PORT/tcp
EXPOSE $SS_PORT/udp

CMD ss-server -s $SS_ADDR     \
              -p $SS_PORT     \
              -k $SS_PASSWORD \
              -m $SS_METHOD   \
              -t $SS_TIMEOUT  \
              -u              \
              -A
