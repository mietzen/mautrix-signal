#!/usr/bin/env bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
STATUS=0

export UID
export GID

export IMAGE="${DOCKER_USER}/mautrix-signal:${VERSION}-${ARCH}-${BUILD_NR}"
cd ${SCRIPT_DIR}

echo ""
echo "Setup"
echo "------------------------------------------------------------"
git clean -fxd
echo ""
docker run --rm \
    --platform ${PLATFORM} \
    --volume ${SCRIPT_DIR}/fixtures/mautrix-signal:/data \
    ${IMAGE}
cp ${SCRIPT_DIR}/fixtures/mautrix-signal/registration.yaml ${SCRIPT_DIR}/fixtures/synapse/registration.yaml
echo ""
docker compose up -d

echo ""
echo "Waiting for Stack to become ready..."
echo "------------------------------------------------------------"
COUNTER=1
while [ ${COUNTER} -le 60 ]; do

if $(docker logs mautrix-signal 2>&1 | grep -q "Connected to signald") && \
    $(docker logs synapse 2>&1 | grep -q "No more background updates to do. Unscheduling background update task"); then
    echo "Stack is ready! breaking wait loop..."
    break 
else
    echo "..."
    docker logs -n 10 synapse
    echo ""
    docker logs -n 10 mautrix-signal
    sleep 10
    COUNTER=$[$COUNTER+1]
    if [ ${COUNTER} -gt 60 ]; then
        echo "Stack not ready after 10 Minutes, breaking wait loop..."
    fi
fi
done

echo ""
echo "Prepare"
echo "------------------------------------------------------------"
echo ""
docker exec -u 0 mautrix-signal apk add --no-cache procps || STATUS=1

echo ""
echo "Test"
echo "------------------------------------------------------------"
inspec exec ./system/host || STATUS=1
inspec exec ./system/container -t docker://mautrix-signal || STATUS=1

echo ""
echo "Teardown"
echo "------------------------------------------------------------"
echo ""
docker compose down --remove-orphans --volumes 
echo ""

echo ""
echo "Result"
echo "------------------------------------------------------------"
if [ $STATUS -eq 0 ]; then
    echo ""
    echo "SUCSSES!"
else
    echo ""
    echo "FAILED!"
    exit 1
fi
