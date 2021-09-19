# Ruby jemalloc base image for Salesloft

## Building

    docker build --platform linux/amd64 -t salesloft/ruby-jemalloc:2.5.5-buster-slim-linux-amd64 .
    docker push salesloft/ruby-jemalloc:2.5.5-buster-slim-linux-amd64

    docker build --platform linux/arm64 -t salesloft/ruby-jemalloc:2.5.5-buster-slim-linux-arm64 .
    docker push salesloft/ruby-jemalloc:2.5.5-buster-slim-linux-arm64

## Creating an pushing

    docker manifest create salesloft/ruby-jemalloc:2.5.5-buster-slim salesloft/ruby-jemalloc:2.5.5-buster-slim-linux-arm64 salesloft/ruby-jemalloc:2.5.5-buster-slim-linux-amd64 --amend
    docker manifest push salesloft/ruby-jemalloc:2.5.5-buster-slim
