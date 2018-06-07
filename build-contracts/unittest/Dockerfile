FROM yolean/node@sha256:9d02ee07572e98ce3db9018ac6ee2a70b12464498d3ea36aca0e9d6fb660eba7

WORKDIR /usr/src/app

COPY package.json .

RUN npm install

COPY . .

RUN npm run unittest
