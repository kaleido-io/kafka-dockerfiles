# This is a dummy, see ./hooks/build
FROM adoptopenjdk:11.0.10_9-jre-hotspot-focal@sha256:e34db425ecac523ea29fa0d3cbefdda89e7e19bceb0fbe0ea4d5b91764003807

RUN java -XX:+PrintFlagsFinal -version | grep -E "UseContainerSupport|MaxRAMPercentage|MinRAMPercentage|InitialRAMPercentage"
