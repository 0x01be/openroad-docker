FROM 0x01be/openroad:build as build

FROM 0x01be/xpra

COPY --from=build /opt/openroad/ /opt/openroad/

USER root

RUN ln -s /usr/lib/libtcl8.6.so /usr/lib/libtcl.so

RUN apk add --no-cache --virtual openroad-runtime-dependencies \
    libstdc++ \
    tcl \
    zlib \
    pcre \
    qt5-qtbase-x11

USER xpra

ENV PATH ${PATH}:/opt/openroad/bin/

ENV COMMAND "openroad -gui"

