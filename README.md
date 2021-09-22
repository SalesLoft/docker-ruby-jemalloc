# Ruby jemalloc base image for Salesloft

Custom Docker image containing a Ruby build with jemalloc. Primarily used as a base image for Melody.

Note: You should not build and push this repository from a laptop. GitHub Actions will build and push using the included Docker workflow.

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
