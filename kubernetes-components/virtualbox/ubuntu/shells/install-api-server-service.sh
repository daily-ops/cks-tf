#!/bin/bash

# For data encryption to be stored in etcd
ENCRYPTION_KEY=$(head -c 32 /dev/urandom | base64)
echo $ENCRYPTION_KEY

cat > encryption-at-rest.yaml <<EOF
kind: EncryptionConfig
apiVersion: v1
resources:
  - resources:
      - secrets
    providers:
      - aescbc:
          keys:
            - name: key1
              secret: ${ENCRYPTION_KEY}
      - identity: {}
EOF

mkdir /var/lib/kubernetes
mv encryption-at-rest.yaml /var/lib/kubernetes

## For audit log
cat > /root/certificates/logging.yaml <<EOF
apiVersion: audit.k8s.io/v1
kind: Policy
rules:
- level: Metadata
EOF

cat <<EOF | sudo tee /etc/systemd/system/kube-apiserver.service
[Unit]
Description=Kubernetes API Server
Documentation=https://github.com/kubernetes/kubernetes

[Service]
ExecStart=/usr/local/bin/kube-apiserver \
--advertise-address=159.65.147.161 \
--etcd-cafile=/root/certificates/ca.crt \
--etcd-certfile=/root/certificates/apiserver.crt \
--etcd-keyfile=/root/certificates/apiserver.key \
--etcd-servers=https://127.0.0.1:2379 \
--service-account-key-file=/root/certificates/service-account.crt \
--service-cluster-ip-range=10.0.0.0/24 \
--service-account-signing-key-file=/root/certificates/service-account.key \
--service-account-issuer=https://127.0.0.1:6443 \
--tls-cert-file=/root/certificates/kube-api.crt \
--tls-private-key-file=/root/certificates/kube-api.key \
--encryption-provider-config=/var/lib/kubernetes/encryption-at-rest.yaml \
--audit-policy-file=/root/certificates/logging.yaml \
--audit-log-path=/var/log/api-audit.log \
--audit-log-maxage=7  --audit-log-maxbackup=5  --audit-log-maxsize=100



[Install]
WantedBy=multi-user.target
EOF