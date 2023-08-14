#!/bin/bash

touch /var/run/signald.sock
chown $UID:$GID /var/run/signald.sock
chown -R $UID:$GID /signald
exec su-exec $UID:$GID /bin/signald -d /signald -s /var/run/signald.sock &

source /opt/mautrix-signal/docker-run.sh
