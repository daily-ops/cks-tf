#!/bin/bash

mkdir /root/certificates && cd /root/certificates

### Server

openssl genrsa -out etcd.key 2048

# Assuming enp0s8 is there
IP_ADDRESS=`ip -4 addr show enp0s8 | grep -oP "(?<=inet ).*(?=/)"`

cat > etcd.cnf <<EOF
[req]
req_extensions = v3_req
distinguished_name = req_distinguished_name
[req_distinguished_name]
[ v3_req ]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = @alt_names
[alt_names]
IP.1 = ${IP_ADDRESS}
IP.2 = 127.0.0.1
EOF

openssl req -new -key etcd.key -subj "/CN=etcd" -out etcd.csr -config etcd.cnf

### Client

openssl genrsa -out client.key 2048
openssl req -new -key client.key -subj "/CN=client" -out client.csr
openssl x509 -req -in client.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out client.crt -extensions v3_req  -days 60