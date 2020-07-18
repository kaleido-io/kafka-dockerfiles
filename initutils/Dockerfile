# same FROM as kafka-jre, to keep pull times down and to provide the same shell distro+version
FROM ubuntu:bionic@sha256:e5b0b89c846690afe2ce325ac6c6bc3d686219cfa82166fc75c812c1011f0803

ENV KUBERNETES_VERSION=1.17.9 KUBERNETES_CLIENT_SHA512=57fe9caf9d40e8b3e9e1b58552af1b74bf3cdccb3bd50fb5e51ba95d3e08263dad831724d79f2b99c0d67b03a1e533667422a20ba4159234b3452cdffbb814d4

RUN set -ex; \
  export DEBIAN_FRONTEND=noninteractive; \
  runDeps='curl ca-certificates procps netcat'; \
  buildDeps=''; \
  apt-get update && apt-get install -y $runDeps $buildDeps --no-install-recommends; \
  rm -rf /var/lib/apt/lists/*; \
  \
  curl -sLS -o k.tar.gz -k https://dl.k8s.io/v${KUBERNETES_VERSION}/kubernetes-client-linux-amd64.tar.gz; \
  echo "$KUBERNETES_CLIENT_SHA512  k.tar.gz" | sha512sum -c; \
  tar -xvzf k.tar.gz -C /usr/local/bin/ --strip-components=3 kubernetes/client/bin/kubectl; \
  rm k.tar.gz; \
  \
  apt-get purge -y --auto-remove $buildDeps; \
  rm /var/log/dpkg.log /var/log/apt/*.log
