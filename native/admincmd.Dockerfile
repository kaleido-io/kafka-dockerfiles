FROM solsson/kafka:graalvm as substitutions

WORKDIR /workspace
COPY substitutions/admincmd .
RUN mvn package

FROM eclipse-temurin:11.0.12_7-jdk-focal@sha256:96d5ec0cd4685fa17731c2ae6206cd9ece0ec9908a36ffb73e43383e37b17824 \
  as nonlibs
RUN echo "class Empty {public static void main(String[] a){}}" > Empty.java && javac Empty.java && jar --create --file /empty.jar Empty.class

FROM curlimages/curl@sha256:aa45e9d93122a3cfdf8d7de272e2798ea63733eeee6d06bd2ee4f2f8c4027d7c \
  as extralibs

USER root
RUN curl -sLS -o /slf4j-nop-1.7.30.jar https://repo1.maven.org/maven2/org/slf4j/slf4j-nop/1.7.30/slf4j-nop-1.7.30.jar
RUN curl -sLS -o /quarkus-kafka-client-1.7.0.Final.jar https://repo1.maven.org/maven2/io/quarkus/quarkus-kafka-client/1.7.0.Final/quarkus-kafka-client-1.7.0.Final.jar

FROM solsson/kafka:nativebase as native

ARG classpath=/opt/kafka/libs/extensions/*:/opt/kafka/libs/*

COPY --from=substitutions /workspace/target/*.jar /opt/kafka/libs/extensions/substitutions.jar
COPY --from=extralibs /*.jar /opt/kafka/libs/extensions/

# docker run --rm --entrypoint ls solsson/kafka -l /opt/kafka/libs/ | grep log
COPY --from=nonlibs /empty.jar /opt/kafka/libs/slf4j-log4j12-1.7.30.jar

COPY configs/{{command}} /home/nonroot/native-config

RUN native-image \
  --no-server \
  --install-exit-handlers \
  -H:+ReportExceptionStackTraces \
  --no-fallback \
  -H:IncludeResourceBundles=joptsimple.HelpFormatterMessages \
  -H:IncludeResourceBundles=joptsimple.ExceptionMessages \
  -H:ConfigurationFileDirectories=/home/nonroot/native-config \
  # When testing the build for a new version we should remove this one, but then it tends to come back
  --initialize-at-build-time \
  # -D options from entrypoint
  -Djava.awt.headless=true \
  -Dkafka.logs.dir=/opt/kafka/bin/../logs \
  -cp ${classpath} \
  -H:Name={{command}} \
  {{mainclass}} \
  /home/nonroot/{{command}}

FROM gcr.io/distroless/base-debian10:nonroot@sha256:4ecb92a78f71a48c681a4d219a9ede869afd6dbedf27bc5dea44aa3e1a38ccea

COPY --from=native \
  /lib/x86_64-linux-gnu/libz.so.* \
  /lib/x86_64-linux-gnu/

COPY --from=native \
  /usr/lib/x86_64-linux-gnu/libzstd.so.* \
  /usr/lib/x86_64-linux-gnu/libsnappy.so.* \
  /usr/lib/x86_64-linux-gnu/liblz4.so.* \
  /usr/lib/x86_64-linux-gnu/

WORKDIR /usr/local

ARG command=
COPY --from=native /home/nonroot/{{command}} ./bin/{{command}}.sh

ENTRYPOINT [ "/usr/local/bin/{{command}}.sh" ]
