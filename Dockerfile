
FROM docker.io/library/golang:1.18-alpine3.17 as signaldctl

RUN apk add --no-cache g++ make git

WORKDIR /src
RUN git clone https://gitlab.com/signald/signald-go.git . && make signaldctl

FROM docker.io/alpine:3.17 AS build

RUN apk add --no-cache jq curl openjdk17 make git

RUN SIGNALD_VERSION=$(curl -s https://gitlab.com/api/v4/projects/7028347/releases/ | jq '.[]' | jq -r '.name' | head -1) && \
    git clone https://gitlab.com/signald/signald.git /tmp/src && \
    cd /tmp/src && git checkout $SIGNALD_VERSION

WORKDIR /tmp/src

RUN make installDist

FROM dock.mau.dev/mautrix/signal:v0.4.3

COPY --from=build /tmp/src/build/install/signald/bin/signald /bin/signald
COPY --from=signaldctl /src/signaldctl /bin/signaldctl
COPY ./entrypoint.sh /entrypoint.sh 

RUN apk add --no-cache openjdk17

RUN /bin/signaldctl config set socketpath /var/run/signald.sock

VOLUME /signald

CMD ["sh", "/entrypoint.sh"]