FROM eclipse-temurin:11.0.12_7-jdk-focal@sha256:96d5ec0cd4685fa17731c2ae6206cd9ece0ec9908a36ffb73e43383e37b17824

ENV KAFKA_MONITOR_REPO=https://github.com/linkedin/kafka-monitor \
    KAFKA_MONITOR_VERSION=2.3.1 \
    KAFKA_MONITOR_SHA256=b08f9f531eefe861042164d92fcb88e08cd79f75e227ffd36f17835501a8a362

RUN set -ex; \
  export DEBIAN_FRONTEND=noninteractive; \
  runDeps=''; \
  buildDeps='curl ca-certificates unzip'; \
  apt-get update && apt-get install -y $runDeps $buildDeps --no-install-recommends; \
  \
  cd /opt; \
  GRADLE_VERSION=4.10.2 PATH=$PATH:$(pwd)/gradle-$GRADLE_VERSION/bin; \
  curl -SLs -o gradle-$GRADLE_VERSION-bin.zip https://services.gradle.org/distributions/gradle-$GRADLE_VERSION-bin.zip; \
  echo "b49c6da1b2cb67a0caf6c7480630b51c70a11ca2016ff2f555eaeda863143a29  gradle-$GRADLE_VERSION-bin.zip" | sha256sum -c -; \
  unzip gradle-$GRADLE_VERSION-bin.zip; \
  rm gradle-$GRADLE_VERSION-bin.zip; \
  gradle -v; \
  \
  mkdir -p /opt/kafka-monitor; \
  curl -o monitor.tar.gz -SLs "$KAFKA_MONITOR_REPO/archive/$KAFKA_MONITOR_VERSION.tar.gz"; \
  echo "$KAFKA_MONITOR_SHA256  monitor.tar.gz" | sha256sum -c; \
  tar -xzf monitor.tar.gz --strip-components=1 -C /opt/kafka-monitor; \
  rm monitor.tar.gz; \
  \
  cd /opt/kafka-monitor; \
  rm gradlew; \
  gradle --no-daemon jar; \
  \
  sed -i 's/localhost:2181/zookeeper:2181/' config/kafka-monitor.properties; \
  sed -i 's/localhost:9092/bootstrap:9092/' config/kafka-monitor.properties; \
  \
  cat config/kafka-monitor.properties; \
  cat config/log4j.properties; \
  \
  rm -rf /opt/gradle* /root/.gradle; \
  \
  apt-get purge -y --auto-remove $buildDeps nodejs; \
  rm -rf /var/lib/apt/lists/*; \
  rm -rf /var/log/dpkg.log /var/log/alternatives.log /var/log/apt

WORKDIR /opt/kafka-monitor

ENTRYPOINT ["./bin/kafka-monitor-start.sh"]
CMD ["/opt/kafka-monitor/config/kafka-monitor.properties"]
