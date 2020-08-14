FROM buildpack-deps:stretch

USER root

ENV LANG=C.UTF-8
ENV HOME=/root

RUN apt-get update && apt-get install -y --no-install-recommends apt-utils

#
# ERLANG
#

ENV ERLANG_VERSION="1:23.0.3-1"

RUN wget https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb && dpkg -i erlang-solutions_1.0_all.deb

RUN apt-get update && \
  apt-get install -yy --no-install-recommends esl-erlang=${ERLANG_VERSION}

#
# ELIXIR
#

ENV ELIXIR_VERSION="v1.10.3"

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

