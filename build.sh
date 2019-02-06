#!/bin/sh -ex
export RUBY_MAJOR=2.6

export RUBY_VERSION=2.6.1

apk update

apk add --no-cache --virtual .ruby-builddeps \
  autoconf \
  bison \
  bzip2 \
  bzip2-dev \
  ca-certificates \
  coreutils \
  curl \
  dpkg-dev dpkg \
  gcc \
  gdbm-dev \
  glib-dev \
  libc-dev \
  libffi-dev \
  libxml2-dev \
  libxslt-dev \
  linux-headers \
  make \
  ncurses-dev \
  openssl \
  openssl-dev \
  procps \
  readline-dev \
  ruby \
  tar \
  xz \
  yaml-dev \
  zlib-dev

update-ca-certificates

curl -f -o ruby.tar.xz "https://cache.ruby-lang.org/pub/ruby/${RUBY_MAJOR%-rc}/ruby-$RUBY_VERSION.tar.xz"
mkdir -p /usr/src/ruby
tar -xJf ruby.tar.xz -C /usr/src/ruby --strip-components=1
rm ruby.tar.xz
curl -f -o '/usr/src/ruby/thread-stack-fix.patch' 'https://bugs.ruby-lang.org/attachments/download/7081/0001-thread_pthread.c-make-get_main_stack-portable-on-lin.patch'
cd /usr/src/ruby

# https://github.com/docker-library/ruby/issues/196
# https://bugs.ruby-lang.org/issues/14387#note-13 (patch source)
# https://bugs.ruby-lang.org/issues/14387#note-16 ("Therefore ncopa's patch looks good for me in general." -- only breaks glibc which doesn't matter here)

patch -p1 -i thread-stack-fix.patch
rm thread-stack-fix.patch

# hack in "ENABLE_PATH_CHECK" disabling to suppress:
#   warning: Insecure world writable dir
{ \
  echo '#define ENABLE_PATH_CHECK 0'; \
  echo; \
  cat file.c; \
} > file.c.new

mv file.c.new file.c
autoconf
gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)"
# the configure script does not detect isnan/isinf as macros
export ac_cv_func_isnan=yes ac_cv_func_isinf=yes
./configure  --build="$gnuArch"  --disable-install-doc  --enable-shared
make -j "$(nproc)"
make install
runDeps="$(scanelf --needed --nobanner --format '%n#p' --recursive /usr/local | tr ',' '\n'  | sort -u \
  | awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
)"
apk add --no-network --virtual .ruby-rundeps $runDeps bzip2 ca-certificates libffi-dev procps yaml-dev zlib-dev
apk del --no-network .ruby-builddeps

cd /
rm -r /usr/src/ruby

# make sure bundled "rubygems" is older than RUBYGEMS_VERSION (https://github.com/docker-library/ruby/issues/246)
export RUBYGEMS_VERSION=3.0.1

# RUN ruby -e 'exit(Gem::Version.create(ENV["RUBYGEMS_VERSION"]) > Gem::Version.create(Gem::VERSION))'
gem update --system "$RUBYGEMS_VERSION" && rm -r /root/.gem/

# rough smoke test
ruby --version && gem --version && bundle --version

# install things globally, for great justice
# and don't create ".bundle" in all our apps
export GEM_HOME=/usr/local/bundle
export BUNDLE_PATH="$GEM_HOME"
export BUNDLE_SILENCE_ROOT_WARNING=1
export BUNDLE_APP_CONFIG="$GEM_HOME"

# path recommendation: https://github.com/bundler/bundler/pull/6469#issuecomment-383235438
export PATH=$GEM_HOME/bin:$BUNDLE_PATH/gems/bin:$PATH

# adjust permissions of a few directories for running "gem install" as an arbitrary user
mkdir -p "$GEM_HOME" && chmod 777 "$GEM_HOME"
# (BUNDLE_PATH = GEM_HOME, no need to mkdir/chown both)
