#!/bin/bash
#
# Sets up the kernel with the requirements for running Kubernetes
set -e

# Add br_netfilter kernel module otherwise it may face this error due to the bridge module missing its directory:
# "Failed to check br_netfilter: stat /proc/sys/net/bridge/bridge-nf-call-iptables: no such file or directory"
modprobe br_netfilter

echo br_netfilter > /etc/modules-load.d/br_netfilter-modules.conf

# Set network tunables
cat <<EOF >> /etc/sysctl.d/10-kubernetes.conf
net.bridge.bridge-nf-call-iptables=1
net.ipv4.ip_forward=1
EOF

systemctl restart systemd-sysctl.service

#net.ipv6.conf.all.disable_ipv6=1
#net.ipv6.conf.default.disable_ipv6=1
#net.ipv6.conf.enp0s3.disable_ipv6=1
#net.ipv6.conf.enp0s8.disable_ipv6=1
