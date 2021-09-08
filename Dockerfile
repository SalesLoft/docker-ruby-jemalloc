FROM debian:stretch-slim

LABEL author=Salesloft

# mostly copied from https://hub.docker.com/layers/hoteltonight/ruby-jemalloc/2.5.5-stretch-slim/images/sha256-c34c6c28f678c19d0fb2fa5fdead59589720f2c0727b6ec24fd6e713fde9e064?context=explore

ENV GEM_HOME=/usr/local/bundle
ENV RUBY_MAJOR=2.5
ENV RUBY_VERSION=2.5.5
ENV RUBY_DOWNLOAD_SHA256=9bf6370aaa82c284f193264cc7ca56f202171c32367deceb3599a4f354175d7d
ENV RUBYGEMS_VERSION=3.0.3
ENV BUNDLE_PATH=/usr/local/bundle BUNDLE_SILENCE_ROOT_WARNING=1 BUNDLE_APP_CONFIG=/usr/local/bundle
ENV PATH=/usr/local/bundle/bin:/usr/local/bundle/gems/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

ENV OS_PACKAGES bzip2 ca-certificates procps wget ruby
ENV BUILD_PACKAGES build-essential autoconf bison libjemalloc-dev libffi-dev libgdbm3 libgmp-dev libssl-dev libyaml-dev zlib1g-dev

RUN install -d -m 775 "$GEM_HOME" /usr/local/etc /usr/src/ruby \
    && { echo 'install: --no-document'; echo 'update: --no-document';  } >> /usr/local/etc/gemrc

RUN /bin/sh -c set -ex \
    && apt-get update \
    && apt-get install -y --no-install-recommends ${OS_PACKAGES} ${BUILD_PACKAGES} \
    && wget --quiet -O ruby.tar.xz "https://cache.ruby-lang.org/pub/ruby/${RUBY_MAJOR%-rc}/ruby-$RUBY_VERSION.tar.xz" \
    && echo "$RUBY_DOWNLOAD_SHA256 *ruby.tar.xz" | sha256sum -c - \
    && mkdir -p /usr/src/ruby \
    && tar -xJf ruby.tar.xz -C /usr/src/ruby --strip-components=1 \
    && rm ruby.tar.xz \
    && cd /usr/src/ruby \
    && { echo '#define ENABLE_PATH_CHECK 0'; echo; cat file.c; } > file.c.new \
    && mv file.c.new file.c \
    && autoconf \
    && gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)" \
    && ./configure --with-jemalloc --build="$gnuArch" --disable-install-doc --enable-shared \
    && make -j "$(nproc)" \
    && make install \
    && apt-get remove -y ${BUILD_PACKAGES} \
    && apt-mark auto '.*' > /dev/null \
    && find /usr/local -type f -executable -not \( -name '*tkinter*' \) -exec ldd '{}' ';' \
        | awk '/=>/ { print $(NF-1) }' \
        | sort -u \
        | xargs -r dpkg-query --search \
        | cut -d: -f1 \
        | sort -u \
        | xargs -r apt-mark manual \
    && apt-mark manual ca-certificates \
    && apt-get -y clean \
    && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
    && rm -rf /var/lib/apt/lists/* \
    && cd / \
    && rm -r /usr/src/ruby \
    && ruby -e 'exit(Gem::Version.create(ENV["RUBYGEMS_VERSION"]) > Gem::Version.create(Gem::VERSION))' \
    && gem update --system "$RUBYGEMS_VERSION" \
    && rm -r /root/.gem/ \
    && ruby --version \
    && gem --version \
    && bundle --version

CMD ["irb"]