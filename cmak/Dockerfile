FROM adoptopenjdk:11.0.9_11-jdk-hotspot-focal@sha256:22fda5482af1e2364248517a9d22991cecd640965938828534e5233b8d9b13eb \
  as build

ENV CMAK_VERSION=3.0.0.5
ENV CMAK_ARCHIVE=https://github.com/yahoo/CMAK/archive/${CMAK_VERSION}.tar.gz

RUN set -ex; \
  export DEBIAN_FRONTEND=noninteractive; \
  runDeps=''; \
  buildDeps='curl ca-certificates unzip apt-transport-https gnupg2 lsb-release'; \
  apt-get update && apt-get install -y $runDeps $buildDeps --no-install-recommends; \
  \
  curl -s https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add -; \
  echo "deb https://deb.nodesource.com/node_8.x stretch main" > /etc/apt/sources.list.d/nodesource.list; \
   apt-get update && apt install -y --no-install-recommends nodejs; \
  \
  mkdir -p /opt/cmak-src; \
  curl -SLs "${CMAK_ARCHIVE}" | tar -xzf - --strip-components=1 -C /opt/cmak-src; \
  \
  cd /opt/cmak-src; \
  ./sbt clean dist; \
  \
  cd /opt; \
  unzip cmak-src/target/universal/cmak-$CMAK_VERSION.zip; \
  mv cmak-$CMAK_VERSION cmak; \
  \
  rm -rf /root/.sbt /root/.ivy2 /opt/cmak-src; \
  \
  apt-get purge -y --auto-remove $buildDeps nodejs; \
  rm -rf /var/lib/apt/lists/*; \
  rm -rf /var/log/dpkg.log /var/log/alternatives.log /var/log/apt

FROM adoptopenjdk:11.0.9_11-jre-hotspot-focal@sha256:f20df8e98a28a75b69f770be59b8431c2f878c29156fc8453fa0c5978857f3aa

COPY --from=build /opt/cmak /opt/cmak

WORKDIR /opt/cmak

ENTRYPOINT ["./bin/cmak"]

# Should be identical to kafka-nonroot's user
RUN echo 'nonroot:x:65532:65534:nonroot:/home/nonroot:/usr/sbin/nologin' >> /etc/passwd && \
  mkdir -p /home/nonroot && touch /home/nonroot/.bash_history && chown -R 65532:65534 /home/nonroot
RUN chmod g+w /opt/cmak && chgrp nogroup /opt/cmak
USER nonroot:nogroup
