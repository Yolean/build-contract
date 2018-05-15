FROM yolean/node@sha256:f033123ae2292d60769e5b8eff94c4b7b9d299648d0d23917319c0743029c5ef

ENV docker_version=17.09.1~ce-0~debian
ENV compose_version=1.21.0 compose_sha256=af639f5e9ca229442c8738135b5015450d56e2c1ae07c0aaa93b7da9fe09c2b0

RUN apt-get update \
  && apt-get install -y apt-transport-https curl ca-certificates gnupg2 \
  && curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add - \
  && apt-key fingerprint 0EBFCD88 \
  && echo "deb [arch=amd64] https://download.docker.com/linux/debian stretch stable" > /etc/apt/sources.list.d/docker.list \
  && apt-get update \
  && apt-get install -y docker-ce=$docker_version \
  && rm -r /var/lib/apt/lists/*

# This image expects a mounted docker.sock or env that points to docker tcp
RUN update-rc.d -f docker remove

RUN curl -L https://github.com/docker/compose/releases/download/$compose_version/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose \
  && sha256sum /usr/local/bin/docker-compose \
  && echo "${compose_sha256} /usr/local/bin/docker-compose" | sha256sum -c - \
  && chmod +x /usr/local/bin/docker-compose

VOLUME /source
WORKDIR /source

COPY package.json build-contract parsetargets /usr/src/app/
COPY nodejs /usr/src/app/nodejs
RUN cd /usr/src/app/ && npm install && npm link

RUN adduser --disabled-password --gecos '' build-contract
RUN chown -R build-contract /usr/src/app
RUN chown -R build-contract /source

USER build-contract

ENTRYPOINT ["build-contract"]
CMD ["push"]
