#!/bin/bash

/bin/signald -d /signald -s /var/run/signald.sock &

source /opt/mautrix-signal/docker-run.sh
