#!/usr/bin/env bash

set -xe

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

cd ${SCRIPT_DIR}

git clean -Fxd

echo "Setup"
docker run --rm -d \ 
    --platform ${PLATFORM} \
    --volume ${SCRIPT_DIR}/fixtures/mautrix-signal:/data \
    docker.io/mietzen/mautrix-signal:v0.4.3

docker compose up -d

# Install tools needed for inspect
docker exec -u 0 mautrix-signal apk add --no-cache procps

echo "Test"
inspec exec ./system -t docker://mautrix-signal

echo "Teardown"
docker compose down --remove-orphans --volumes 
