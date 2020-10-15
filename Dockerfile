FROM 0x01be/swig:3.0 as swig
FROM 0x01be/eigen as eigen

FROM alpine as builder

RUN apk add --no-cache --virtual build-dependencies \
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
    qt5-qtbase-dev

COPY --from=swig /opt/swig/ /opt/swig/
COPY --from=eigen /opt/eigen/ /opt/eigen/

ENV SWIG_VERSION=3.0.12
ENV SWIG_DIR /opt/swig/share/swig/$SWIG_VERSION/
ENV SWIG_EXECUTABLE /opt/swig/bin/swig
ENV PATH $PATH:/opt/swig/bin/

ENV LEMON_VERSION 1.3.1

ADD http://lemon.cs.elte.hu/pub/sources/lemon-${LEMON_VERSION}.tar.gz /lemon-${LEMON_VERSION}.tar.gz
WORKDIR /
RUN tar xzf lemon-${LEMON_VERSION}.tar.gz
WORKDIR /lemon-${LEMON_VERSION}/build
RUN cmake \
    -DCMAKE_INSTALL_PREFIX=/opt/lemon \
    ..
RUN make
RUN make install 

RUN git clone --recursive https://github.com/The-OpenROAD-Project/OpenROAD /openroad

WORKDIR /openroad/build

ENV LD_LIBRARY_PATH /lib/:/usr/lib:/opt/lemon/lib/
ENV C_INCLUDE_PATH /usr/include/:/opt/lemon/include/:/opt/eigen/include/
ENV CMAKE_PREFIX_PATH ${CMAKE_PREFIX_PATH}:/opt/eigen

RUN sed -i.bak 's/PAGE_SIZE/PAGE_SIZE_OPENDB/g' /openroad/src/OpenDB/src/zutil/misc_functions.cpp
RUN sed -i.bak 's/PAGE_SIZE/PAGE_SIZE_OPENDB/g' /openroad/src/OpenDB/src/db/dbAttrTable.h
RUN sed -i.bak 's/PAGE_SIZE/PAGE_SIZE_OPENDB/g' /openroad/src/OpenDB/src/db/dbPagedVector.h
RUN ln -s /usr/lib/libtcl8.6.so /usr/lib/libtcl.so

RUN cmake \
    -DCMAKE_INSTALL_PREFIX=/opt/openroad \
    -DEigen3_DIR=/opt/eigen/ \
    ..
RUN make
RUN make install
RUN chmod +x /opt/openroad/bin/*

