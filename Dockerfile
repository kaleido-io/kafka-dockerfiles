# This is a dummy, see ./hooks/build
FROM adoptopenjdk:11.0.9_11-jre-hotspot-focal@sha256:f20df8e98a28a75b69f770be59b8431c2f878c29156fc8453fa0c5978857f3aa

RUN java -XX:+PrintFlagsFinal -version | grep -E "UseContainerSupport|MaxRAMPercentage|MinRAMPercentage|InitialRAMPercentage"
