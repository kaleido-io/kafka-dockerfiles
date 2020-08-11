# This is a dummy, see ./hooks/build
FROM adoptopenjdk:11.0.8_10-jre-hotspot-bionic@sha256:26e3b4204eb7f4984059e56bfc356d574bea58bfd2ef9b15ee5c70ff552a1699

RUN java -XX:+PrintFlagsFinal -version | grep -E "UseContainerSupport|MaxRAMPercentage|MinRAMPercentage|InitialRAMPercentage"
