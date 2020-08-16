FROM solsson/kafka:graalvm as substitutions

WORKDIR /workspace
COPY substitutions/zookeeper-server-start .
RUN mvn package

FROM curlimages/curl@sha256:aa45e9d93122a3cfdf8d7de272e2798ea63733eeee6d06bd2ee4f2f8c4027d7c \
  as extralibs

USER root
RUN curl -sLS -o /slf4j-simple-1.7.30.jar https://repo1.maven.org/maven2/org/slf4j/slf4j-simple/1.7.30/slf4j-simple-1.7.30.jar
RUN curl -sLS -o /log4j-over-slf4j-1.7.30.jar https://repo1.maven.org/maven2/org/slf4j/log4j-over-slf4j/1.7.30/log4j-over-slf4j-1.7.30.jar

FROM solsson/kafka:nativebase as native

#ARG classpath=/opt/kafka/libs/slf4j-log4j12-1.7.30.jar:/opt/kafka/libs/log4j-1.2.17.jar:/opt/kafka/libs/slf4j-api-1.7.30.jar:/opt/kafka/libs/zookeeper-3.5.8.jar:/opt/kafka/libs/zookeeper-jute-3.5.8.jar
COPY --from=substitutions /workspace/target/*.jar /opt/kafka/libs/extensions/substitutions.jar
COPY --from=extralibs /*.jar /opt/kafka/libs/extensions/
ARG classpath=/opt/kafka/libs/extensions/substitutions.jar:/opt/kafka/libs/slf4j-api-1.7.30.jar:/opt/kafka/libs/extensions/slf4j-simple-1.7.30.jar:/opt/kafka/libs/extensions/log4j-over-slf4j-1.7.30.jar:/opt/kafka/libs/zookeeper-3.5.8.jar:/opt/kafka/libs/zookeeper-jute-3.5.8.jar:/opt/kafka/libs/jetty-server-9.4.24.v20191120.jar:/opt/kafka/libs/jetty-util-9.4.24.v20191120.jar:/opt/kafka/libs/jetty-io-9.4.24.v20191120.jar:/opt/kafka/libs/jetty-http-9.4.24.v20191120.jar:/opt/kafka/libs/jetty-servlet-9.4.24.v20191120.jar:/opt/kafka/libs/netty-handler-4.1.50.Final.jar:/opt/kafka/libs/netty-buffer-4.1.50.Final.jar:/opt/kafka/libs/javax.servlet-api-3.1.0.jar

COPY configs/zookeeper-server-start /home/nonroot/native-config

# Remaining issues:
# - java.lang.NoClassDefFoundError: Could not initialize class org.apache.zookeeper.server.admin.JettyAdminServer
#   which is fine because https://github.com/apache/zookeeper/blob/release-3.5.7/zookeeper-server/src/main/java/org/apache/zookeeper/server/admin/AdminServerFactory.java
#   documents that admin server is optional and it's only at startup

RUN native-image \
  --no-server \
  --install-exit-handlers \
  -H:+ReportExceptionStackTraces \
  --no-fallback \
  -H:ConfigurationFileDirectories=/home/nonroot/native-config \
  --initialize-at-build-time \
  --initialize-at-run-time=org.apache.zookeeper.server.persistence.FileTxnLog \
  --initialize-at-run-time=org.apache.zookeeper.server.persistence.TxnLogToolkit \
  --initialize-at-run-time=org.apache.zookeeper.server.persistence.FilePadding \
  # Added because of io.netty.buffer.Unpooled.wrappedBuffer(byte[]), org.eclipse.jetty.servlet.ServletContextHandler.<init>(int)
  --allow-incomplete-classpath \
  # -D options from entrypoint
  -Djava.awt.headless=true \
  -Dkafka.logs.dir=/opt/kafka/bin/../logs \
  # -Dlog4j.configuration=file:/etc/kafka/log4j.properties \
  -cp ${classpath} \
  -H:Name=zookeeper-server-start \
  org.apache.zookeeper.server.quorum.QuorumPeerMain \
  /home/nonroot/zookeeper-server-start

FROM gcr.io/distroless/base-debian10:nonroot@sha256:f4a1b1083db512748a305a32ede1d517336c8b5bead1c06c6eac2d40dcaab6ad

COPY --from=native \
  /lib/x86_64-linux-gnu/libz.so.* \
  /lib/x86_64-linux-gnu/

COPY --from=native \
  /usr/lib/x86_64-linux-gnu/libzstd.so.* \
  /usr/lib/x86_64-linux-gnu/libsnappy.so.* \
  /usr/lib/x86_64-linux-gnu/liblz4.so.* \
  /usr/lib/x86_64-linux-gnu/

WORKDIR /usr/local
COPY --from=native /home/nonroot/zookeeper-server-start ./bin/zookeeper-server-start.sh
COPY --from=native /etc/kafka /etc/kafka

ENTRYPOINT [ "/usr/local/bin/zookeeper-server-start.sh" ]
CMD ["/etc/kafka/zookeeper.properties"]
