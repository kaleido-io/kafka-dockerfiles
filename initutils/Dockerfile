# same FROM as kafka-jre, to keep pull times down and to provide the same shell distro+version
FROM ubuntu:focal@sha256:b4f9e18267eb98998f6130342baacaeb9553f136142d40959a1b46d6401f0f2b

ENV KUBERNETES_VERSION=1.20.4 KUBERNETES_CLIENT_SHA512=daf1ec0cbd14885170a51d2a09bf652bfaa4d26925c1b4babdc427d2a2903b1a295403320229cde2b415fee65a5af22671afa926f184cf198df7f17a27f19394

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
