FROM yolean/node@sha256:e591eac6f5d1f07876bd63bba2bbd1c1218521c5ed5312692851597b47089775

WORKDIR /usr/src/app

COPY package.json .

RUN npm install

COPY . .

RUN npm run unittest
