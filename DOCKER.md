# Docker for BH Macs

## Reference

Introduction presentation video at YAPC...

[2016 - More Modern Perl with Docker - Jason Hall](https://www.youtube.com/watch?v=V7-a3giGuDA)

[The Getting Started Docker Guide](https://docs.docker.com/machine/get-started/) is a resource that I highly recoomend reading through.

Perhaps looked through the [Docker-Toolbox Reference](https://docs.docker.com/docker-for-mac/docker-toolbox/)?

## Manual Install (no docker-toolbox)

  brew install docker
  brew install docker-machine
  brew install caskroom/cask/virtualbox
  brew install docker-compose

## Create our first docker-machine

  docker-machine create --driver virtualbox default

To verify...

  docker-machine ls

Setting environment variables to connect your shell to the new machine.

  eval "$(docker-machine env default)"

## Run Docker

  docker run busybox echo hello world

## Setup Alpine

  docker pull alpine

## Build container

  docker build -t kay9zero/mimir .
