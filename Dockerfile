FROM alpine:3.21

ARG NDPPD_VERSION=master

COPY patch/logger.patch /tmp/
COPY entrypoint.sh /

RUN apk --no-cache add --virtual .build-dependencies make g++ linux-headers patch wget ca-certificates \
	&& mkdir -p /usr/src \
	&& wget -qO- https://github.com/DanielAdolfsson/ndppd/archive/${NDPPD_VERSION}.tar.gz | tar -xzC /usr/src \
	&& cd /usr/src/ndppd-${NDPPD_VERSION} \
	&& patch src/logger.cc < /tmp/logger.patch \
	&& wget -qO- https://sources.debian.org/data/main/n/ndppd/0.2.5-6/debian/patches/pid_perms | patch -p1 \
	&& make -j && make install \
	&& rm -rf /usr/local/share/man \
	&& cd / && rm -rf /usr/src/ndppd-${NDPPD_VERSION} \
	&& apk del .build-dependencies \
	&& apk --no-cache add libstdc++

ENTRYPOINT ["/entrypoint.sh"]
