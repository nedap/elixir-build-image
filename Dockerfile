FROM buildpack-deps:stretch

USER root

ENV LANG=C.UTF-8
ENV HOME=/root

RUN apt-get update && apt-get install -y --no-install-recommends apt-utils

#
# ERLANG
#

ENV ERLANG_VERSION="23.2"

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

ENV ELIXIR_VERSION="v1.11.2"

RUN set -xe \
  && ELIXIR_DOWNLOAD_URL="https://github.com/elixir-lang/elixir/releases/download/${ELIXIR_VERSION}/Precompiled.zip" \
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
# Node + Yarn
#

RUN curl -sL https://deb.nodesource.com/setup_14.x | bash -
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update && apt-get install -y yarn

