FROM docker.io/library/golang:1.18-alpine3.17 as signaldctl

RUN apk add --no-cache alpine-sdk

WORKDIR /src
RUN git clone https://gitlab.com/signald/signald-go.git . && \
    make signaldctl

FROM docker.io/library/amazoncorretto:17-alpine3.17 AS build

RUN apk add --no-cache jq curl git zip

RUN SIGNALD_VERSION=$(curl -s https://gitlab.com/api/v4/projects/7028347/releases/ | jq '.[]' | jq -r '.name' | head -1) && \
    git clone https://gitlab.com/signald/signald.git /tmp/src && \
    cd /tmp/src && \
    git checkout $SIGNALD_VERSION

ADD https://services.gradle.org/distributions/gradle-7.3.3-bin.zip /tmp/gradle-7.3.3-bin.zip
RUN mkdir /opt/gradle && \
    unzip -d /opt/gradle /tmp/gradle-7.3.3-bin.zip

WORKDIR /tmp/src
RUN VERSION=$(./version.sh) /opt/gradle/gradle-7.3.3/bin/gradle -Dorg.gradle.daemon=false runtime

FROM dock.mau.dev/mautrix/signal:v0.4.3

# Somehow needed, otherwise we end up with: 
# Error: Unable to initialize main class io.finn.signald.Main
# Caused by: java.lang.ExceptionInInitializerError: null
# When running signald
WORKDIR /

COPY --from=build /tmp/src/build/image /
COPY --from=signaldctl /src/signaldctl /bin/signaldctl
COPY ./entrypoint.sh /entrypoint.sh 

RUN adduser --disabled-password --uid 1337 signald && \
    mkdir /signald && \
    mkdir /var/run/signald && \
    chown -R signald:signald /signald && \
    chown signald:signald /var/run/signald

RUN sed -i 's:/signald/signald.sock:/var/run/signald/signald.sock:g' /opt/mautrix-signal/docker-run.sh

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8
ENV UID=1337 GID=1337

USER signald
RUN /bin/signaldctl config set socketpath /var/run/signald/signald.sock
VOLUME /signald

USER root
CMD ["sh", "/entrypoint.sh"]