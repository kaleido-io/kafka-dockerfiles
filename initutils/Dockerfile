# same FROM as kafka-jre, to keep pull times down and to provide the same shell distro+version
FROM ubuntu:focal@sha256:b4f9e18267eb98998f6130342baacaeb9553f136142d40959a1b46d6401f0f2b

ENV KUBERNETES_VERSION=1.17.14 KUBERNETES_CLIENT_SHA512=027945e245693c4c0dfd818eb7b4213d21d90b2d0191d9d62c218e150ee1e604ba8b9f329704ef4089327abf3be9fa31672dd637d7518efe80fb03e40fbe6e37

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
