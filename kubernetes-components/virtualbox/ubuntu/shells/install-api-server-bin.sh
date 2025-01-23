#!/bin/bash

wget https://dl.k8s.io/v1.24.2/kubernetes-server-linux-amd64.tar.gz
tar -xzvf kubernetes-server-linux-amd64.tar.gz
cp kubernetes/server/bin/kube-apiserver kubectl /usr/local/bin/
rm -rf kubernetes
rm -f kubernetes-server-linux-amd64.tar.gz