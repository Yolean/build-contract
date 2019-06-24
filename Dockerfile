FROM ubuntu:18.04@sha256:9b1702dcfe32c873a770a32cfd306dd7fc1c4fd134adfb783db68defc8894b3c

RUN set -ex; \
  export DEBIAN_FRONTEND=noninteractive; \
  runDeps=''; \
  buildDeps='curl ca-certificates'; \
  apt-get update && apt-get install -y $runDeps $buildDeps --no-install-recommends; \
  \
  echo done
#  \
#  apt-get purge -y --auto-remove $buildDeps; \
#  rm -rf /var/lib/apt/lists/*; \
#  rm -rf /var/log/dpkg.log /var/log/alternatives.log /var/log/apt /etc/ssl/certs /root/.gnupg

#https://github.com/docker/docker-install/raw/master/rootless-install.sh

RUN apt-get install -y --no-install-recommends kmod

RUN set -e; \
  apt-get install -y uidmap; \
  apt-get install -y iptables; \
  modprobe ip_tables;

RUN useradd -m -s /bin/sh -u 1000 -U dockerd
USER dockerd
WORKDIR /home/dockerd

RUN set -ex; \
  curl -sLS -o rootless-install.sh https://github.com/docker/docker-install/raw/e12ac635bd447fe2efc3724022a5dd1cb15d47a8/rootless-install.sh; \
  sed -i 's|STATIC_RELEASE_URL=.*|STATIC_RELEASE_URL=https://download.docker.com/linux/static/test/x86_64/docker-19.03.0-rc3.tgz|' rootless-install.sh; \
  sed -i 's|STATIC_RELEASE_ROOTLESS_URL=.*|STATIC_RELEASE_ROOTLESS_URL=https://download.docker.com/linux/static/test/x86_64/docker-rootless-extras-19.03.0-rc3.tgz|' rootless-install.sh; \
  chmod u+x rootless-install.sh; \
  ./rootless-install.sh
