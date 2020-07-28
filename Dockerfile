FROM docker:19.03.12-dind@sha256:97b189e06e3a9ea76ed51a852b7117a914241dfba09bfeed9779668ef3d106ed

RUN apk add --no-cache curl nodejs npm bash git python2

# https://github.com/docker/compose/issues/3465
RUN apk add --no-cache --virtual .docker-compose-deps \
  py-pip python-dev libffi-dev openssl-dev gcc libc-dev make \
  && pip install docker-compose==1.25.5 \
  && apk del .docker-compose-deps

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
