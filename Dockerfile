FROM 0x01be/openroad:build as build

FROM 0x01be/xpra

COPY --from=build /opt/openroad/ /opt/openroad/
COPY --from=build /openroad/src/OpenDB/build/ /opt/opendb/
COPY --from=build /openroad/src/OpenDB/include/opendb/db.h /opt/opendb/include/opendb/

RUN apk add --no-cache --virtual openroad-runtime-dependencies \
    libstdc++ \
    tcl \
    zlib \
    pcre \
    libgomp \
    gmp \
    qt5-qtbase \
    qt5-qtbase-x11 \
    qt5-qtdeclarative \
    qt5-qtwayland \
    mesa-dri-swrast \
    spdlog &&\
    apk add --no-cache --virtual openroad-edge-runtime-dependencies \
    --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing \
    --repository http://dl-cdn.alpinelinux.org/alpine/edge/community \
    --repository http://dl-cdn.alpinelinux.org/alpine/edge/main \
    glpk &&\
    ln -s /usr/lib/libtcl8.6.so /usr/lib/libtcl.so

USER ${USER}
ENV PATH=${PATH}:/opt/openroad/bin/ \
    COMMAND="openroad -gui"

