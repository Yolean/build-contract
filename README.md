# build-contract
Defines a successful build and test run for a microservice, from source to docker push

## using locally

Invoke build-contract in current folder, use host's docker:
```
docker build --tag yolean/build-contract .
docker run -v /var/run/docker.sock:/var/run/docker.sock -v $(pwd)/:/source  --rm --name mybuild -e PUSH_TAG=testing yolean/build-contract test
```

Or for monorepo:
```
docker run -v /var/run/docker.sock:/var/run/docker.sock -v $(pwd)/../:/source -w /source/$(basename $(pwd)) --rm --name mybuild -e PUSH_TAG=testing yolean/build-contract test
```

Add `-t` for colors and Ctrl+C support.

There are automated builds [solsson/build-contract](https://hub.docker.com/r/solsson/build-contract).

## Node.js monorepo support with `npm``

Add scripts to `package.json` like so, and build contract will pick them up:

```
  "scripts": {
    "build-contract-predockerbuild": "./node_modules/.bin/build-contract-predockerbuild",
    "packagelock": "build-contract-packagelock",
```

Paths depend on your npm install situation.
