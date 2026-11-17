FROM --platform=$TARGETPLATFORM docker:29.4.1-cli@sha256:17b5c235f40be7432a7c0914c154e9278aed63bad4afe5607e4f91840696a9f8 \
  as docker

# Same nodejs base as github.com/Yolean/ystack runner.Dockerfile, used by github.com/Yolean/docker-base builder images
FROM --platform=$TARGETPLATFORM node:26.13.0-trixie-slim@sha256:5adad64f9a1fca2d51972caa65983634c8a774eb300d72b20f7f2a0f60368072

RUN set -ex \
  && export DEBIAN_FRONTEND=noninteractive \
  && apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    git \
  && rm -rf /var/lib/apt/lists/* /var/log/apt /var/log/dpkg.log /var/log/alternatives.log

COPY --from=docker /usr/local/bin/docker /usr/local/bin/
COPY --from=docker /usr/local/libexec/docker/cli-plugins /usr/local/libexec/docker/cli-plugins

ENV npm_config_update_notifier=false

VOLUME /source
WORKDIR /source

COPY package.json /usr/src/app/
RUN cd /usr/src/app/ && npm install --omit=dev
COPY build-contract parsetargets /usr/src/app/
COPY nodejs /usr/src/app/nodejs
RUN cd /usr/src/app/ && npm link --omit=dev

RUN echo '#!/bin/sh' > /usr/local/bin/shasum && echo 'sha1sum $@' >> /usr/local/bin/shasum && chmod a+x /usr/local/bin/shasum

ENTRYPOINT ["build-contract"]
CMD ["push"]

# --ignore-scripts would leave the shebang-less placeholder pnpm 12 ships in place of its native binary
RUN npm install -g --ignore-scripts pnpm@12.16.1 && node "$(npm root -g)/pnpm/install.js"
