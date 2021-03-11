FROM gradle:7.0.2-jdk11 as builder

COPY --chown=gradle:gradle . /home/gradle/src

WORKDIR /home/gradle/src

RUN ./gradlew build --info

FROM openjdk:11.0.11-jre-slim

RUN mkdir -p /app/releases
RUN mkdir -p /app/configs
RUN mkdir -p /app/storage

VOLUME /app/storage

ENV DB_DATABASE=/app/storage/db

COPY --from=builder /home/gradle/src/build/libs/crab-0.0.1.jar /app/releases/crab-0.0.1.jar
COPY --from=builder /home/gradle/src/config.properties /app/configs/config.properties

EXPOSE 8000

ENTRYPOINT ["java", "-jar", "/app/releases/crab-0.0.1.jar", "--spring.config.name=config"]
