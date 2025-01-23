#!/bin/bash

set -x

if [ $# -ne 2 ]; then
    echo "Usage: $0 <known host file> <ip>"
    echo "Example: $0 /home/ansible/.ssh/known_hosts 192.168.0.100"
    exit 1
fi
KNOWN_HOST_FILE=$1
IP=$2

if [ ! -f $KNOWN_HOST_FILE ]; then
    touch $KNOWN_HOST_FILE
fi

if [ "$(grep ${IP} $KNOWN_HOST_FILE)" != "" ]; then
    sed -i -e "/^${IP}.*/d" $KNOWN_HOST_FILE
fi

ssh-keyscan $IP >> $KNOWN_HOST_FILE
RET_CODE=$?
while [ $RET_CODE -ne 0 ]; do
    sed -i -e "/^${IP}.*/d" $KNOWN_HOST_FILE
    ssh-keyscan $IP >> $KNOWN_HOST_FILE
    RET_CODE=$?
done
set +x