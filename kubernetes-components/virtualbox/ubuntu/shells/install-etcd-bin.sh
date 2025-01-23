#!/bin/bash

VERSION=3.5.4

wget https://github.com/etcd-io/etcd/releases/download/v$VERSION/etcd-v$VERSION-linux-amd64.tar.gz
tar -xzvf etcd-v$VERSION-linux-amd64.tar.gz
cp etcd-v$VERSION-linux-amd64/etcd  /usr/local/bin/
cp etcd-v$VERSION-linux-amd64/etcdctl
rm -rf etcd-v$VERSION-linux-amd64
rm -f etcd-v$VERSION-linux-amd64.tar.gz
