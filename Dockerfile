FROM alpine:3.5
WORKDIR /tmp
COPY build.sh build.sh
RUN /bin/sh -ex build.sh
