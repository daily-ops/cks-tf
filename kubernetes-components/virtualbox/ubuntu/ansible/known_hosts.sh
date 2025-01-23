#!/bin/bash

set -x

if [ ! -f /home/ansible/.ssh/known_hosts ]; then
    touch /home/ansible/.ssh/known_hosts
fi

if [ "$(grep ${1} /home/ansible/.ssh/known_hosts)" != "" ]; then
    sed -i -e "/^${1}.*/d" /home/ansible/.ssh/known_hosts
fi

ssh-keyscan $1 >> /home/ansible/.ssh/known_hosts
RET_CODE=$?
while [ $RET_CODE -ne 0 ]; do
    sed -i -e "/^${1}.*/d" /home/ansible/.ssh/known_hosts
    ssh-keyscan $1 >> /home/ansible/.ssh/known_hosts
    RET_CODE=$?
done
set +x