FROM docker:20.10.7-dind@sha256:4e1e22f471afc7ed5e024127396f56db392c1b6fc81fc0c05c0e072fb51909fe

RUN apk add --no-cache curl nodejs npm bash git

COPY --from=docker/compose:alpine-1.26.2@sha256:b60a020c0f68047b353a4a747f27f5e5ddb17116b7b018762edfb6f7a6439a82 \
  /usr/local/bin/docker-compose /usr/local/bin/docker-compose

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
