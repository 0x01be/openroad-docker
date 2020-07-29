FROM 0x01be/swig:3.0 as swig

FROM alpine:3.12.0 as builder

RUN apk add --no-cache --virtual build-dependencies \
    --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing \
    --repository http://dl-cdn.alpinelinux.org/alpine/edge/community \
    --repository http://dl-cdn.alpinelinux.org/alpine/edge/main \
    git \
    build-base \
    cmake \
    bison \
    flex \
    boost-dev \
    tcl-dev \
    zlib-dev \
    eigen-dev \
    autoconf \
    automake \
    pcre-dev

COPY --from=swig /opt/swig/ /opt/swig/

ENV SWIG_VERSION=3.0.12
ENV SWIG_DIR /opt/swig/share/swig/$SWIG_VERSION/
ENV SWIG_EXECUTABLE /opt/swig/bin/swig
ENV PATH $PATH:/opt/swig/bin/

RUN git clone --recursive https://github.com/The-OpenROAD-Project/OpenROAD /openroad

# FIXME
#RUN mkdir /openroad/build
#WORKDIR /openroad/build

#RUN cmake ..
#RUN make
#RUN make install

