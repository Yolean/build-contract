FROM docker:19.03.2-dind@sha256:615eb3922630a30a52f7c46760f3d08a9eb4a1b0474d038281af8eade8c43f40

ENV compose_version=1.21.0 compose_sha256=af639f5e9ca229442c8738135b5015450d56e2c1ae07c0aaa93b7da9fe09c2b0

RUN apk add --no-cache curl nodejs npm bash

RUN curl -sLSo /usr/local/bin/docker-compose https://github.com/docker/compose/releases/download/$compose_version/docker-compose-`uname -s`-`uname -m` \
  && sha256sum /usr/local/bin/docker-compose \
  && echo "${compose_sha256}  /usr/local/bin/docker-compose" | sha256sum -c - \
  && chmod +x /usr/local/bin/docker-compose

VOLUME /source
WORKDIR /source

COPY package.json /usr/src/app/
RUN cd /usr/src/app/ && npm install --production
COPY build-contract parsetargets /usr/src/app/
COPY nodejs /usr/src/app/nodejs
RUN cd /usr/src/app/ && npm link --only=production

ENTRYPOINT ["build-contract"]
CMD ["push"]
