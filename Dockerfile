FROM mgoltzsche/podman@sha256:2ae8f2589055515543bad762f16cc752cc0bd20926a10da8d5300f6ca024f9bf \
  as static-binaries

FROM moby/buildkit:master-rootless@sha256:e0871752631c6236c0c933cc2986f6b8f212d50a4d79d8f96ae1c3aba8a99d63

USER root
RUN apk add --no-cache curl
COPY --from=static-binaries /usr/local/bin/slirp4netns /usr/local/bin/slirp4netns
USER user

RUN set -ex; \
  cd $HOME; \
  curl -sLS -o rootless-install.sh https://github.com/docker/docker-install/raw/e12ac635bd447fe2efc3724022a5dd1cb15d47a8/rootless-install.sh; \
  sed -i 's|STATIC_RELEASE_URL=.*|STATIC_RELEASE_URL=https://download.docker.com/linux/static/test/x86_64/docker-19.03.0-rc3.tgz|' rootless-install.sh; \
  sed -i 's|STATIC_RELEASE_ROOTLESS_URL=.*|STATIC_RELEASE_ROOTLESS_URL=https://download.docker.com/linux/static/test/x86_64/docker-rootless-extras-19.03.0-rc3.tgz|' rootless-install.sh; \
  chmod u+x rootless-install.sh; \
  SKIP_IPTABLES=1 ./rootless-install.sh

ENTRYPOINT [ "/home/dockerd/bin/dockerd-rootless.sh" \
  "--experimental", \
  "--iptables=false", \
  "--storage-driver", "vfs" \
  ]
