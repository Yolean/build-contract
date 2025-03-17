FROM --platform=$TARGETPLATFORM docker:28.0.1-cli@sha256:18018c4b6e75bab6b93e04159c83778c98b60b0f95c762967bb501d684553daf

RUN apk add --no-cache \
  docker-compose \
  curl \
  nodejs \
  npm \
  bash \
  git

VOLUME /source
WORKDIR /source

COPY package.json /usr/src/app/
RUN cd /usr/src/app/ && npm install --production
COPY build-contract parsetargets /usr/src/app/
COPY nodejs /usr/src/app/nodejs
RUN cd /usr/src/app/ && npm link --only=production

RUN echo '#!/bin/sh' > /usr/local/bin/shasum && echo 'sha1sum $@' >> /usr/local/bin/shasum && chmod a+x /usr/local/bin/shasum

ENTRYPOINT ["build-contract"]
CMD ["push"]
