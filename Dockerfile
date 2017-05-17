FROM centos:7

RUN \
    yum -y update --setopt=tsflags=nodocs \
    && yum -y install --setopt=tsflags=nodocs epel-release \
    && yum -y install --setopt=tsflags=nodocs git make wget gcc

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

RUN \
    wget https://packages.erlang-solutions.com/erlang-solutions-1.0-1.noarch.rpm \
    && rpm -Uvh erlang-solutions-1.0-1.noarch.rpm

RUN yum -y install erlang --setopt=tsflags=nodocs

RUN \
    wget https://github.com/elixir-lang/elixir/archive/v1.4.4.tar.gz \
    && tar xf v1.4.4.tar.gz

WORKDIR /elixir-1.4.4

RUN make clean install

WORKDIR /app

COPY . .

RUN rm -rf /app/_build /app/deps

ENV MIX_ENV prod

RUN mix local.rebar --force && \
    mix local.hex --force && \
    mix deps.get && \
    mix release --env=prod

