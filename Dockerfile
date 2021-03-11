# To build
# $ docker build -t clivern/crap:0.0.1 .
#
# To Run
# $ docker run -d \
#    --env APP_PORT=8000 \
#    --env DB_CONNECTION=h2 \
#    --env DB_HOST=127.0.0.1 \
#    --env DB_PORT=3306 \
#    --env DB_DATABASE=/app/storage/db \
#    --env DB_USERNAME=root \
#    --env DB_PASSWORD=secret \
#    --name=crap \
#    --publish 8000:8000 \
#    clivern/crap:0.0.1

FROM gradle:7.0.2-jdk11 as builder

COPY --chown=gradle:gradle . /home/gradle/src

WORKDIR /home/gradle/src

RUN ./gradlew build --info

FROM openjdk:11.0.11-jre-slim

RUN mkdir -p /app/releases
RUN mkdir -p /app/configs
RUN mkdir -p /app/storage

VOLUME /app/storage

ENV APP_PORT=8080
ENV DB_DATABASE=/app/storage/db

COPY --from=builder /home/gradle/src/build/libs/crab-0.0.1.jar /app/releases/crab-0.0.1.jar
COPY --from=builder /home/gradle/src/.env.example /app/configs/.env

EXPOSE 8000

ENTRYPOINT ["java", "-jar", "/app/releases/crab-0.0.1.jar", "--env=/app/configs/.env"]
