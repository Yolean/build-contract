FROM yolean/node@sha256:a0141027783eb712197efe3ac1b42726da0da1c72ecafed99991ddf511086427

ENV docker_version=5:19.03.1~3-0~debian-stretch
ENV compose_version=1.21.0 compose_sha256=af639f5e9ca229442c8738135b5015450d56e2c1ae07c0aaa93b7da9fe09c2b0

RUN apt-get update \
  && apt-get install -y apt-transport-https curl ca-certificates gnupg2 \
  && curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add - \
  && apt-key fingerprint 0EBFCD88 \
  && echo "deb [arch=amd64] https://download.docker.com/linux/debian stretch stable" > /etc/apt/sources.list.d/docker.list \
  && apt-get update \
  && apt-cache madison docker-ce-cli \
  && apt-get install -y docker-ce-cli=$docker_version \
  && rm -r /var/lib/apt/lists/*

# This image expects a mounted docker.sock or env that points to docker tcp
RUN update-rc.d -f docker remove

RUN curl -L https://github.com/docker/compose/releases/download/$compose_version/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose \
  && sha256sum /usr/local/bin/docker-compose \
  && echo "${compose_sha256} /usr/local/bin/docker-compose" | sha256sum -c - \
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
