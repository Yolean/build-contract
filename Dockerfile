FROM docker:19.03.4-dind@sha256:681e31208cbeb26f63ac9a006a38fd88e0fde21187115bc76cee2bf94fb93a12

RUN apk add --no-cache curl nodejs npm docker-compose bash git

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
