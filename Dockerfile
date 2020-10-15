FROM 0x01be/openroad:build as build

FROM alpine

COPY --from=build /opt/openroad/ /opt/openroad/

RUN ln -s /usr/lib/libtcl8.6.so /usr/lib/libtcl.so

RUN apk add --no-cache --virtual openroad-runtime-dependencies \
    libstdc++ \
    tcl \
    zlib \
    pcre \
    qt5-qtbase-x11

ENV PATH ${PATH}:/opt/openroad/bin/

RUN adduser -D -u 1000 openroad
WORKDIR /workspace
RUN chown openroad:openroad /workspace

USER openroad

