#!/usr/bin/env bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
STATUS=0
cd ${SCRIPT_DIR}

echo ""
echo "Setup"
echo "------------------------------------------------------------"
git clean -fxd
echo ""
docker run --rm \
    --platform ${PLATFORM} \
    --volume ${SCRIPT_DIR}/fixtures/mautrix-signal:/data \
    docker.io/mietzen/mautrix-signal:v0.4.3
echo ""
docker compose up -d

echo ""
echo "Waiting for Stack to become ready..."
echo "------------------------------------------------------------"
COUNTER=1
while [ ${COUNTER} -le 12 ]; do

if $(docker logs mautrix-signal 2>&1 | grep -q "Connected to signald") && $(docker logs synapse 2>&1 | grep -q "No more background updates to do. Unscheduling background update task"); then
    echo "Stack is ready! breaking wait loop..."
    break 
else
    echo "..."
    sleep 10
    COUNTER=$[$COUNTER+1]
    if [ ${COUNTER} -gt 12 ]; then
        echo "Stack not ready after 120 seconds, breaking wait loop..."
    fi
fi
done

# Install tools needed for inspect
docker exec -u 0 mautrix-signal apk add --no-cache procps || STATUS=1

echo ""
echo "Test"
echo "------------------------------------------------------------"
echo ""
inspec exec ./system/host || STATUS=1
echo ""
inspec exec ./system/container -t docker://mautrix-signal || STATUS=1

echo ""
echo "Teardown"
echo "------------------------------------------------------------"
echo ""
docker compose down --remove-orphans --volumes 
echo ""
git clean -fxd

if [ $STATUS -eq 1 ]; then
    echo "FAILED!"
    exit 1
fi
