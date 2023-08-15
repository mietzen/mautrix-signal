#!/bin/bash

exec su-exec $UID:$GID /bin/signald -d /signald -s /var/run/signald/signald.sock &

source /opt/mautrix-signal/docker-run.sh
