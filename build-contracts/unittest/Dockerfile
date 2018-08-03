FROM yolean/node@sha256:751e8947b2ce0f416a3a69ed2413703b109754383a0eb1cefbf74b199233bf7c

WORKDIR /usr/src/app

COPY package.json .

RUN npm install

COPY . .

RUN npm run unittest
