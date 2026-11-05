FROM --platform=$TARGETPLATFORM docker:29.9.3-cli@sha256:4d742ab934c2149b628bf26369ac3ec51cb91e2e28fe6722a0e86a6d6efc4bd5

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

# --ignore-scripts would leave the shebang-less placeholder pnpm 12 ships in place of its native binary
RUN npm install -g --ignore-scripts pnpm@12.16.1 && node "$(npm root -g)/pnpm/install.js"
