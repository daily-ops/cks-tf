#!/bin/bash

set -x

if [ $# -ne 3 ]; then
    echo "Usage: $0 <known host file> <ip> <hostname>"
    echo "Example: $0 /home/ansible/.ssh/known_hosts 192.168.0.100 node01"
    exit 1
fi
KNOWN_HOST_FILE=$1
IP=$2
KNOWN_HOSTNAME=$3

if [ ! -f $KNOWN_HOST_FILE ]; then
    touch $KNOWN_HOST_FILE
fi

if [ "$(grep ${IP} $KNOWN_HOST_FILE)" != "" ]; then
    sed -i -e "/^${IP}.*/d" $KNOWN_HOST_FILE
fi

if [ -f ~/.ssh/known_hosts ]; then
    if [ "$(grep ${IP} ~/.ssh/known_hosts)" != "" ]; then
        sed -i -e "/^${IP}.*/d" ~/.ssh/known_hosts
    fi
fi

FINGER_PRINT=`ssh-keyscan -t rsa "$IP,$KNOWN_HOSTNAME"`
#  >> $KNOWN_HOST_FILE
RET_CODE=$?
while [ $RET_CODE -ne 0 ]; do
    sed -i -e "/^${IP}.*/d" $KNOWN_HOST_FILE
    FINGER_PRINT=`ssh-keyscan -t rsa "$IP,$KNOWN_HOSTNAME"`
    # ssh-keyscan -t rsa "$IP,$KNOWN_HOSTNAME" >> $KNOWN_HOST_FILE
    RET_CODE=$?
done
echo $FINGER_PRINT >> $KNOWN_HOST_FILE
echo $FINGER_PRINT >> ~/.ssh/known_hosts
set +x