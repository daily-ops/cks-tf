#!/bin/bash

# etcd client certificate
openssl genrsa -out apiserver.key 2048
openssl req -new -subj "/CN=kube-apiserver" -key apiserver.key -out apiserver.csr
openssl x509 -req -in apiserver.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out apiserver.crt -days 60

# kube-api server certificate
IP_ADDRESS=`ip -4 addr show enp0s8 | grep -oP "(?<=inet ).*(?=/)"`

cat <<EOF | sudo tee api.conf
[req]
req_extensions = v3_req
distinguished_name = req_distinguished_name
[req_distinguished_name]
[ v3_req ]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = @alt_names
[alt_names]
DNS.1 = kubernetes
DNS.2 = kubernetes.default
DNS.3 = kubernetes.default.svc
DNS.4 = kubernetes.default.svc.cluster.local
IP.1 = 127.0.0.1
IP.2 = ${IP_ADDRESS}
IP.3 = 10.0.0.1
EOF

openssl req -new -subj "/CN=kube-apiserver" -key kube-api.key -out kube-api.csr -config api.conf
openssl x509 -req -in kube-api.csr -CA ca.crt -CAkey ca.key -CAcreateserial -extensio
ns v3_req -extfile api.conf -days 60 -out kube-api.crt 
