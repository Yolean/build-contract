FROM --platform=$TARGETPLATFORM docker/compose:alpine-1.29.2@sha256:ae66070588c539b965986dc74e9371e3e62ef71668b72a5eed70de111ed3659e \
  as compose

FROM --platform=$TARGETPLATFORM docker:20.10.16-dind@sha256:d8b7b9468fe6dc26f008f6eadafa2845dc0408a3c5e86fc9e04f6bcc2d98bf13

RUN apk add --no-cache curl nodejs npm bash git

COPY --link --from=compose /usr/local/bin/docker-compose /usr/local/bin/docker-compose

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
