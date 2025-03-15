FROM --platform=$TARGETPLATFORM docker:28.0.1-dind@sha256:ddf7f6fd0d2175709739f1d47e6134fa8eb055d2f61c11c3f99780c79b44578e

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
