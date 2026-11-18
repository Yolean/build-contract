FROM --platform=$TARGETPLATFORM docker:29.9.3-cli@sha256:4d742ab934c2149b628bf26369ac3ec51cb91e2e28fe6722a0e86a6d6efc4bd5 \
  as docker

# Provides nodejs, npm, pnpm, git and curl, and is already pulled by the cicd pods that run build-contract
FROM --platform=$TARGETPLATFORM ghcr.io/yolean/builder-base:092e54bdc2ee88d14efbec16c85613e353ebbd7c@sha256:1747e8e6f245d440b2c1ecd785c1e138c8582466ce1b6cd0d60b46fbbb695714

USER root

# Static binaries, independent of the base image's libc
COPY --from=docker /usr/local/bin/docker /usr/local/bin/
COPY --from=docker /usr/local/libexec/docker/cli-plugins /usr/local/libexec/docker/cli-plugins

COPY package.json /usr/src/app/
RUN cd /usr/src/app/ && npm install --omit=dev
COPY build-contract parsetargets /usr/src/app/
COPY nodejs /usr/src/app/nodejs
RUN cd /usr/src/app/ && npm link --omit=dev

RUN echo '#!/bin/sh' > /usr/local/bin/shasum && echo 'sha1sum $@' >> /usr/local/bin/shasum && chmod a+x /usr/local/bin/shasum

USER nonroot:nogroup

VOLUME /source
WORKDIR /source

ENTRYPOINT ["build-contract"]
CMD ["push"]
