#
#  Description:
#
#    This Dockerfile is base for ruby execution environment.
#    Ruby install by rbenv.
#    Ruby install to system wide(/usr/local/rbenv).
#
#  Build:
#
#    Default(ruby-2.4.1):
#
#      docker build -t ruby:latest ./
#
#    Specified ruby version:
#
#      RUBY_VERSION=2.4.0
#      docker build -t ruby:${RUBY_VERSION} --build-arg RUBY_VERSION=${RUBY_VERSION} ./
#
#  ARGS:
#
#    RUBY_VERSION: ruby version for install by rbenv
#
FROM centos:7.3.1611
LABEL maintainer="maehachi08"

ARG RUBY_VERSION
ENV RUBY_VERSION ${RUBY_VERSION:-2.4.1}

ADD files/rbenv.sh /etc/profile.d/

RUN set -x && \

    # system update
    yum update -y && \

    # install epel
    yum install -y epel-release && \

    # install rpms
    yum install -y \
        make \
        git \
        gcc \
        gcc-c++ \
        bzip2 \
        openssl-devel \
        readline-devel \
        python-pip && \

    # upgrade pip
    pip install --upgrade pip && \

    # install aws cli
    pip install awscli && \

    # install rbenv
    git clone git://github.com/sstephenson/rbenv.git /usr/local/rbenv && \
    git clone git://github.com/sstephenson/ruby-build.git /usr/local/rbenv/plugins/ruby-build && \
    chmod 644 /etc/profile.d/rbenv.sh && \
    source /etc/profile.d/rbenv.sh && \
    /usr/local/rbenv/bin/rbenv install ${RUBY_VERSION} && \
    /usr/local/rbenv/bin/rbenv global ${RUBY_VERSION} && \
    
    # install bundler
    /usr/local/rbenv/shims/gem install bundler && \

    # bundle install
    # **please ADD Gemfile, and bundle install**

    # delete yum cache
    yum clean all

