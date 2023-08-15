#!/usr/bin/env bash

export DOCKER_USER='mietzen'                                                      
export ARCH='arm64'
export BUILD_NR='0'
export PLATFORM='linux/arm64'
export VERSION='0.0.0'

export USER_ID=$(id -u)                                                           
export GROUPE_ID=$(id -g)
export IMAGE="${DOCKER_USER}/mautrix-signal:${VERSION}-${ARCH}-${BUILD_NR}"
export SCRIPT_DIR=$(pwd)

