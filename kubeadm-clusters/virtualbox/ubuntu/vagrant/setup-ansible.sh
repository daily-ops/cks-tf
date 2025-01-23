#!/bin/bash

apt update

# Install ansible
apt install -y ansible

# Allow only ansible user to execute ansible binaries
chmod 500 $(which ansible)
chmod 500 $(which ansible-playbook)
chmod 500 $(which ansible-inventory)
chmod 500 $(which ansible-connection)

echo "ansible ALL=(ALL) NOPASSWD:ALL" | tee /etc/sudoers.d/ansible