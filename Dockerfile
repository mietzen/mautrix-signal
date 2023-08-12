
FROM docker.io/library/golang:1.21-alpine as signaldctl

RUN apk add --no-cache alpine-sdk

WORKDIR /src
RUN git clone https://gitlab.com/signald/signald-go.git . && make signaldctl

FROM docker.io/library/gradle:7-jdk17-alpine AS build

RUN apk add --no-cache jq alpine-sdk

RUN SIGNALD_VERSION=$(curl -s https://gitlab.com/api/v4/projects/7028347/releases/ | jq '.[]' | jq -r '.name' | head -1) && \
    git clone https://gitlab.com/signald/signald.git /tmp/src && \
    cd /tmp/src && git checkout $SIGNALD_VERSION

WORKDIR /tmp/src

ARG CI_BUILD_REF_NAME
ARG CI_COMMIT_SHA
ARG USER_AGENT

RUN VERSION=$(./version.sh) gradle -Dorg.gradle.daemon=false runtime

FROM dock.mau.dev/mautrix/signal:v0.4.3

COPY --from=build /tmp/src/build/image /
COPY --from=signaldctl /src/signaldctl /bin/signaldctl
COPY ./entrypoint.sh /entrypoint.sh 

RUN /bin/signaldctl config set socketpath /var/run/signald.sock

VOLUME /signald

CMD ["sh", "/entrypoint.sh"]