FROM --platform=$TARGETPLATFORM docker:29.4.1-cli@sha256:17b5c235f40be7432a7c0914c154e9278aed63bad4afe5607e4f91840696a9f8

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
