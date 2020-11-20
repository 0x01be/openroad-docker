FROM 0x01be/openroad:build as build

FROM 0x01be/xpra

RUN apk add --no-cache --virtual openroad-runtime-dependencies \
    libstdc++ \
    tcl \
    zlib \
    pcre \
    qt5-qtbase-x11 \
    mesa-dri-swrast

COPY --from=build /opt/openroad/ /opt/openroad/

RUN ln -s /usr/lib/libtcl8.6.so /usr/lib/libtcl.so

USER ${USER}
ENV PATH=${PATH}:/opt/openroad/bin/ \
    COMMAND="openroad -gui"

