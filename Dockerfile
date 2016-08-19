FROM debian:jessie

ENV docker_version=1.11.2-0~jessie
ENV compose_version=1.8.0

RUN apt-get update \
  && apt-get install -y apt-transport-https curl ca-certificates \
  && apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D \
  && echo "deb https://apt.dockerproject.org/repo debian-jessie main" > /etc/apt/sources.list.d/docker.list \
  && apt-get update \
  && apt-get install -y docker-engine=$docker_version \
  && rm -r /var/lib/apt/lists/*

RUN curl -L https://github.com/docker/compose/releases/download/$compose_version/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose \
  && chmod +x /usr/local/bin/docker-compose

# This image expects a mounted docker.sock or env that points to docker tcp
RUN update-rc.d -f docker remove

VOLUME /source
WORKDIR /source

ENTRYPOINT build-contract
ADD build-contract /usr/local/bin/