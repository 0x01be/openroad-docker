FROM 0x01be/swig:3.0 as swig
FROM 0x01be/eigen as eigen
FROM 0x01be/cudd as cudd

FROM alpine as builder

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
    spdlog-dev

RUN git clone --recursive https://github.com/The-OpenROAD-Project/OpenROAD.git /openroad

COPY --from=swig /opt/swig/ /opt/swig/
COPY --from=eigen /opt/eigen/ /opt/eigen/
COPY --from=cudd /opt/cudd/ /opt/cudd/

ENV LEMON_VERSION=1.3.1 \
    SWIG_VERSION=3.0.12 \
    SWIG_EXECUTABLE=/opt/swig/bin/swig \
    PATH=${PATH}:/opt/swig/bin/ \
    LD_LIBRARY_PATH=/lib/:/usr/lib:/opt/cudd/lib/:/opt/coin-or/lib/ \
    C_INCLUDE_PATH=/usr/include/:/opt/eigen/include/:/opt/cudd/include/:/opt/coin-or/include \
    CMAKE_PREFIX_PATH=${CMAKE_PREFIX_PATH}:/opt/eigen:/opt/cudd:/opt/coin-or
ENV SWIG_DIR /opt/swig/share/swig/${SWIG_VERSION}/

ADD http://lemon.cs.elte.hu/pub/sources/lemon-${LEMON_VERSION}.tar.gz /lemon-${LEMON_VERSION}.tar.gz
WORKDIR /
RUN tar xzf lemon-${LEMON_VERSION}.tar.gz

WORKDIR /lemon-${LEMON_VERSION}/build

RUN apk add --no-cache --virtual openroad-edge-build-dependencies \
    --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing \
    --repository http://dl-cdn.alpinelinux.org/alpine/edge/community \
    --repository http://dl-cdn.alpinelinux.org/alpine/edge/main \
    glpk-dev

RUN cmake \
    -DCMAKE_INSTALL_PREFIX=/opt/lemon \
    ..
RUN make
RUN make install 

RUN mkdir /opt/openroad && cp -R /openroad /opt/openroad/src

WORKDIR /openroad/build

RUN sed -i.bak 's/PAGE_SIZE/PAGE_SIZE_OPENDB/g' /openroad/src/OpenDB/src/zutil/misc_functions.cpp
RUN sed -i.bak 's/PAGE_SIZE/PAGE_SIZE_OPENDB/g' /openroad/src/OpenDB/src/db/dbAttrTable.h
RUN sed -i.bak 's/PAGE_SIZE/PAGE_SIZE_OPENDB/g' /openroad/src/OpenDB/src/db/dbPagedVector.h
RUN ln -s /usr/lib/libtcl8.6.so /usr/lib/libtcl.so

ENV LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/opt/lemon/lib/ \
    C_INCLUDE_PATH=${C_INCLUDE_PATH}:/opt/lemon/include/ \
    CMAKE_PREFIX_PATH=${CMAKE_PREFIX_PATH}:/opt/lemon

RUN cmake \
    -DCMAKE_INSTALL_PREFIX=/opt/openroad \
    -DEigen3_DIR=/opt/eigen/ \
    ..
RUN make
RUN make install
RUN chmod +x /opt/openroad/bin/*

