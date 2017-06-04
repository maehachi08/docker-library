<<<<<<< HEAD
# docker-library
=======
# ruby-docker

## Description

  This Dockerfile is base for ruby execution environment.

  Ruby install by rbenv.

  Ruby install to system wide(/usr/local/rbenv).

## Build

### 1. Default(ruby-2.4.1)

 ```sh
docker build -t ruby:latest ./
```

### 2. Specified ruby version

 ```sh
RUBY_VERSION=2.4.0
docker build -t ruby:${RUBY_VERSION} --build-arg RUBY_VERSION=${RUBY_VERSION} ./
```

## ARGS

 ```
RUBY_VERSION: ruby version for install by rbenv
```

>>>>>>> first commit
