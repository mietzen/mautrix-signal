FROM docker.io/library/golang:1.18-alpine3.17 as signaldctl

RUN apk add --no-cache alpine-sdk

WORKDIR /src
RUN git clone https://gitlab.com/signald/signald-go.git . && make signaldctl

FROM docker.io/amazoncorretto:17-alpine3.17 AS build

RUN apk add --no-cache jq curl git zip

RUN SIGNALD_VERSION=$(curl -s https://gitlab.com/api/v4/projects/7028347/releases/ | jq '.[]' | jq -r '.name' | head -1) && \
    git clone https://gitlab.com/signald/signald.git /tmp/src && \
    cd /tmp/src && git checkout $SIGNALD_VERSION

ADD https://services.gradle.org/distributions/gradle-7.6.1-bin.zip /tmp/gradle-7.6.1-bin.zip
RUN mkdir /opt/gradle && \
    unzip -d /opt/gradle /tmp/gradle-7.6.1-bin.zip

WORKDIR /tmp/src
RUN VERSION=$(./version.sh) /opt/gradle/gradle-7.6.1/bin/gradle -Dorg.gradle.daemon=false runtime

FROM dock.mau.dev/mautrix/signal:v0.4.3

# Somehow needed, otherwise we end up with: 
# Error: Unable to initialize main class io.finn.signald.Main
# Caused by: java.lang.ExceptionInInitializerError: null
# When running signald
WORKDIR /

COPY --from=build /tmp/src/build/image /
COPY --from=signaldctl /src/signaldctl /bin/signaldctl
COPY ./entrypoint.sh /entrypoint.sh 

RUN /bin/signaldctl config set socketpath /var/run/signald.sock

VOLUME /signald

CMD ["sh", "/entrypoint.sh"]