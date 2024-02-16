ARG buildpack_tag=buster
FROM buildpack-deps:${buildpack_tag}

USER root

ENV LANG=C.UTF-8
ENV HOME=/root

RUN if [ ! $(lsb_release -cs) = "stretch" ]; then bash -c "sed -i 's/http:/https:/g' /etc/apt/sources.list"; fi;

RUN apt-get update && apt-get install -y --no-install-recommends apt-utils \
  lsb-release software-properties-common

#
# Clang for JIT.
# C++17 support is needed, and LLVM does not provide a package for it.
#
RUN if [ ! $(lsb_release -cs) = "stretch" ]; then bash -c "$(wget -O - https://apt.llvm.org/llvm.sh)"; fi;

#
# ERLANG
#

ENV ERLANG_VERSION="25.3.2.8"

RUN apt-get update &&\
  apt-get install -y -q build-essential make &&\
  apt-get install -y -q openssl libssl-dev libncurses5-dev &&\
  apt-get autoremove -y --purge &&\
  apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV KERL_URL "https://raw.githubusercontent.com/kerl/kerl/master/kerl"

RUN curl -O -s ${KERL_URL} &&\
  chmod a+x kerl &&\
  mv kerl /usr/bin

ENV KERL_CONFIGURE_OPTIONS "--with-microstate-accounting=extra \
  --without-edoc \
  --without-erl_docgen \
  --without-ftp \
  --without-odbc \
  --without-ssh \
  --without-ftp \
  --without-tftp"

RUN kerl update releases &&\
  MAKEFLAGS="-j8" kerl build ${ERLANG_VERSION} ${ERLANG_VERSION} &&\
  kerl install ${ERLANG_VERSION} /opt/erlang/${ERLANG_VERSION} &&\
  echo ". /opt/erlang/${ERLANG_VERSION}/activate" >> /etc/bash.bashrc &&\
  ln -s /opt/erlang/${ERLANG_VERSION}/bin/erl /usr/local/bin/erl &&\
  erl -version

#
# ELIXIR
#

ENV ELIXIR_DOWNLOAD_URL="https://github.com/elixir-lang/elixir/releases/download/v1.14.5/elixir-otp-25.zip"

RUN set -xe \
  && buildDeps=' \
  unzip \
  ' \
  && apt-get update \
  && apt-get install -y --no-install-recommends $buildDeps \
  && curl -fSL -o elixir-precompiled.zip $ELIXIR_DOWNLOAD_URL \
  && unzip -d /usr/local elixir-precompiled.zip \
  && rm elixir-precompiled.zip

#
# Hex  + Rebar
#

ENV MIX_ENV=prod

RUN mix local.hex --force
RUN mix local.rebar --force

#
# NODE
#

ENV NODE_VERSION="16.13.1"

# install node version manager (nvm)
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
ENV NVM_DIR=/root/.nvm

# install node
RUN . "$NVM_DIR/nvm.sh" && nvm install ${NODE_VERSION}
RUN . "$NVM_DIR/nvm.sh" && nvm use v${NODE_VERSION}
RUN . "$NVM_DIR/nvm.sh" && nvm alias default v${NODE_VERSION}
ENV PATH="/root/.nvm/versions/node/v${NODE_VERSION}/bin/:${PATH}"

# install yarn
RUN npm install --global yarn
