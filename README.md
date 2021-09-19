# Ruby jemalloc base image for Salesloft

## Building multiple architectures

    docker build --platform linux/amd64 -t salesloft/ruby-jemalloc:2.5.5-buster-slim-linux-amd64 .
    docker push salesloft/ruby-jemalloc:2.5.5-buster-slim-linux-amd64

    docker build --platform linux/arm64 -t salesloft/ruby-jemalloc:2.5.5-buster-slim-linux-arm64 .
    docker push salesloft/ruby-jemalloc:2.5.5-buster-slim-linux-arm64

## Creating the manifest and pushing to Docker Hub

    docker manifest create salesloft/ruby-jemalloc:2.5.5-buster-slim \
        --amend salesloft/ruby-jemalloc:2.5.5-buster-slim-linux-amd64 \
        --amend salesloft/ruby-jemalloc:2.5.5-buster-slim-linux-arm64
    docker manifest push salesloft/ruby-jemalloc:2.5.5-buster-slim
