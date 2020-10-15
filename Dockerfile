FROM 0x01be/swig:3.0 as swig

FROM alpine as builder

RUN apk add --no-cache --virtual build-dependencies \
    git \
    build-base \
    cmake \
    bison \
    flex \
    boost-dev \
    tcl-dev \
    zlib-dev \
    autoconf \
    automake \
    pcre-dev

COPY --from=swig /opt/swig/ /opt/swig/

ENV SWIG_VERSION=3.0.12
ENV SWIG_DIR /opt/swig/share/swig/$SWIG_VERSION/
ENV SWIG_EXECUTABLE /opt/swig/bin/swig
ENV PATH $PATH:/opt/swig/bin/

RUN git clone --depth 1 https://gitlab.com/libeigen/eigen.git /eigen

WORKDIR /eigen/build/
RUN cmake \
    -DCMAKE_INSTALL_PREFIX=/opt/eigen \
    ..
RUN make
RUN make install

RUN git clone --recursive https://github.com/The-OpenROAD-Project/OpenROAD /openroad


WORKDIR /openroad/build

ADD http://lemon.cs.elte.hu/pub/sources/lemon-1.3.1.tar.gz ./lemon-1.3.1.tar.gz

RUN tar xzf lemon-1.3.1.tar.gz
WORKDIR /openroad/build/lemon-1.3.1/build
RUN cmake \
    -DCMAKE_INSTALL_PREFIX=/opt/lemon \
    ..
RUN make
RUN make install

WORKDIR /openroad/build

ENV LD_LIBRARY_PATH /lib/:/usr/lib/:/opt/eigen/lib/:/opt/lemon/lib/
ENV C_INCLUDE_PATH /usr/include/:/opt/eigen/include/:/opt/lemon/include/

RUN cmake \
    -DCMAKE_INSTALL_PREFIX=/opt/openroad \
    ..
RUN make
RUN make install

