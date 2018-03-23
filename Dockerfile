FROM yolean/node:sha256:ebdf2658467fb8408c242bdde9ec6714c838ff3612041f46e57b4717acdc0a84

ENV docker_version=1.13.1-0~debian-jessie
ENV compose_version=1.11.2

RUN apt-get update \
  && apt-get install -y apt-transport-https curl ca-certificates \
  && apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D \
  && echo "deb https://apt.dockerproject.org/repo debian-jessie main" > /etc/apt/sources.list.d/docker.list \
  && apt-get update \
  && apt-get install -y docker-engine=$docker_version \
  && rm -r /var/lib/apt/lists/*

# This image expects a mounted docker.sock or env that points to docker tcp
RUN update-rc.d -f docker remove

RUN curl -L https://github.com/docker/compose/releases/download/$compose_version/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose \
  && chmod +x /usr/local/bin/docker-compose

VOLUME /source
WORKDIR /source

COPY package.json build-contract parsetargets /usr/src/app/
RUN cd /usr/src/app/ && npm install && ln -s /usr/src/app/build-contract /usr/local/bin/build-contract
ENTRYPOINT ["build-contract"]
CMD ["push"]
