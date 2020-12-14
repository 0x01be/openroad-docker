FROM 0x01be/swig:3.0 as swig
FROM 0x01be/eigen as eigen
FROM 0x01be/cudd as cudd
FROM 0x01be/coin as coin
FROM 0x01be/lemon as lemon

FROM 0x01be/base as build

COPY --from=swig /opt/swig/ /opt/swig/
COPY --from=eigen /opt/eigen/ /opt/eigen/
COPY --from=cudd /opt/cudd/ /opt/cudd/
COPY --from=coin /opt/coin/ /opt/coin/
COPY --from=lemon /opt/lemon/ /opt/lemon/

ENV SWIG_VERSION=3.0.12 \
    SWIG_EXECUTABLE=/opt/swig/bin/swig \
    PATH=${PATH}:/opt/swig/bin/ \
    LD_LIBRARY_PATH=/lib/:/usr/lib:/opt/cudd/lib/:/opt/coin/lib/:/opt/lemon/lib/ \
    C_INCLUDE_PATH=/usr/include/:/opt/eigen/include/:/opt/cudd/include/:/opt/coin/include/:/opt/lemon/include/ \
    CMAKE_PREFIX_PATH=${CMAKE_PREFIX_PATH}:/opt/eigen:/opt/cudd:/opt/coin:/opt/lemon
ENV SWIG_DIR /opt/swig/share/swig/${SWIG_VERSION}/

RUN apk add --no-cache --virtual openroad-build-dependencies \
    git \
    build-base \
    cmake \
    coreutils \
    bison \
    flex \
    boost-dev \
    tcl-dev \
    zlib-dev \
    autoconf \
    automake \
    pcre-dev \
    qt5-qtbase-dev \
    qt5-qtdeclarative-dev \
    qt5-qtwayland \
    gmp-dev \
    spdlog-dev \
    python3-dev &&\
    git clone --recursive https://github.com/The-OpenROAD-Project/OpenROAD.git /openroad &&\
    apk add --no-cache --virtual openroad-edge-build-dependencies \
    --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing \
    --repository http://dl-cdn.alpinelinux.org/alpine/edge/community \
    --repository http://dl-cdn.alpinelinux.org/alpine/edge/main \
    glpk-dev &&\
    apk add --no-cache --virtual openroad-doc-dependencies \
    doxygen \
    graphviz &&\
    mkdir /opt/openroad && cp -R /openroad /opt/openroad/src &&\
    sed -i.bak 's/PAGE_SIZE/PAGE_SIZE_OPENDB/g' /openroad/src/OpenDB/src/zutil/misc_functions.cpp &&\
    sed -i.bak 's/PAGE_SIZE/PAGE_SIZE_OPENDB/g' /openroad/src/OpenDB/src/db/dbAttrTable.h &&\
    sed -i.bak 's/PAGE_SIZE/PAGE_SIZE_OPENDB/g' /openroad/src/OpenDB/src/db/dbPagedVector.h &&\
    ln -s /usr/lib/libtcl8.6.so /usr/lib/libtcl.so

WORKDIR /openroad/build
RUN cmake \
    -DCMAKE_INSTALL_PREFIX=/opt/openroad \
    -DEigen3_DIR=/opt/eigen/ \
    -DCUDD_LIB=/opt/cudd/lib/libcudd.a \
    .. &&\
    make
RUN make install && chmod +x /opt/openroad/bin/*

WORKDIR /openroad/src/OpenDB/build
RUN cmake \
    -DCMAKE_INSTALL_PREFIX=/opt/openroad \
    .. &&\
    make

