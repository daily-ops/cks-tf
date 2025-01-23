#!/bin/bash

export NUM_WORKER_NODES=2
export INVENTORY=$PWD/kubeadm-clusters/ansible/inventory
export ANSIBLE_DIR=$PWD/kubeadm-clusters/ansible
export VAGRANT_CWD=$PWD/kubeadm-clusters/virtualbox
export CNI=cilium

function snapshot_and_start() {
    vboxmanage controlvm controlplane poweroff
    for i in $(seq 1 $NUM_WORKER_NODES); do
        vboxmanage controlvm node0${i} poweroff
    done

    vboxmanage snapshot controlplane take $1
    for i in $(seq 1 $NUM_WORKER_NODES); do
        vboxmanage snapshot node0${i} take $1
    done

    vboxmanage startvm controlplane --type=headless
    for i in $(seq 1 $NUM_WORKER_NODES); do
        vboxmanage startvm node0${i} --type=headless
    done
}


function restore_snapshot() {
    vboxmanage controlvm controlplane poweroff
    for i in $(seq 1 $NUM_WORKER_NODES); do
        vboxmanage controlvm node0${i} poweroff
    done

    vboxmanage snapshot controlplane restore $1
    for i in $(seq 1 $NUM_WORKER_NODES); do
        vboxmanage snapshot node0${i} restore $1
    done

    vboxmanage startvm controlplane --type=headless
    for i in $(seq 1 $NUM_WORKER_NODES); do
        vboxmanage startvm node0${i} --type=headless
    done
}

function start() {
    vboxmanage startvm controlplane --type=headless
    for i in $(seq 1 $NUM_WORKER_NODES); do
        vboxmanage startvm node0${i} --type=headless
    done
}

function create_cluster() {
    ansible-playbook -i $INVENTORY $ANSIBLE_DIR/ubuntu/kubeadm-init.yml
}

function join_nodes() {
    ansible-playbook -i $INVENTORY $ANSIBLE_DIR/common/kubeadm-join-nodes.yml --e ansible_dir=$ANSIBLE_DIR
}

function vagrant_up() {
    vagrant up
}

function cni() {
    if [ "$CNI" == "cilium" ]; then
        ansible-playbook -i $INVENTORY $ANSIBLE_DIR/common/deploy-cilium.yml --e ansible_dir=$ANSIBLE_DIR
    elif [ "$CNI" == "flannel" ]; then
        ansible-playbook -i $INVENTORY $ANSIBLE_DIR/common/deploy-flannel.yml --e ansible_dir=$ANSIBLE_DIR
    elif [ "$CNI" == "calico" ]; then
        ansible-playbook -i $INVENTORY $ANSIBLE_DIR/common/deploy-calico.yml --e ansible_dir=$ANSIBLE_DIR
    fi
}

function ingress() {
    ansible-playbook -i $INVENTORY $ANSIBLE_DIR/common/deploy-ingress.yml --e ansible_dir=$ANSIBLE_DIR
}

function security() {
    ansible-playbook -i $INVENTORY $ANSIBLE_DIR/ubuntu/deploy-falco.yml --e repo_root=$PWD
    ansible-playbook -i $INVENTORY $ANSIBLE_DIR/common/deploy-gvisor.yml --e ansible_dir=$ANSIBLE_DIR
    ansible-playbook -i $INVENTORY $ANSIBLE_DIR/common/setup-sample-apparmor.yml --e ansible_dir=$ANSIBLE_DIR
}
function post_deploy() {
    ansible-playbook -i $INVENTORY $ANSIBLE_DIR/common/setup-mysql-dirs.yml --e repo_root=$PWD
    ansible-playbook -i $INVENTORY $ANSIBLE_DIR/common/setup-vault-dirs.yml --e repo_root=$PWD
}

function teardown() {
    vagrant destroy -f
}

function configure() {

    # Create the cluster
    create_cluster
    sleep 30

     # Take a clean snapshot
    snapshot_and_start "blank-kube-cluster"
    sleep 40

    # Join the nodes
    join_nodes
    sleep 40

    # Deploy CNI
    cni

    # Deploy Ingress
    ingress

    # Deploy security tools
    security

    # Post deploy
    post_deploy
}
if [ "$1" == "setup" ]; then
    rm -f /var/tmp/controlplane-ip.out
    rm -f /var/tmp/workstation-ip.out
    rm -f /var/tmp/hosts.tmp
    rm -f /var/tmp/known_hosts
    for i in {1..NUM_WORKER_NODES}; do
        rm -f /var/tmp/node0${i}-ip.out
    done
    
    # VM
    vagrant_up

    sleep 30

    # Take a clean snapshot
    snapshot_and_start "blank-machines"

    sleep 30



    configure

    exit 0
elif [ "$1" == "teardown" ]; then
    vagrant destroy -f
    exit 0
elif [ "$1" == "start" ]; then
    start
    exit 0
elif [ "$1" == "stop" ]; then
    vagrant halt
    exit 0
elif [ "$1" == "restore-machines" ]; then
    restore_snapshot "blank-machines"
    exit 0
elif [ "$1" == "restore-cluster" ]; then
    restore_snapshot "blank-kube-cluster"
    exit 0
elif [ "$1" == "configure" ]; then
    configure
    exit 0
elif [ "$1" == "cni" ]; then
    cni
    exit 0
elif [ "$1" == "ingress" ]; then
    ingress
    exit 0
elif [ "$1" == "security-tools" ]; then
    security
    exit 0
else
    echo "Usage: $0 setup|teardown|stop|restore-machines|restore-cluster|configure|cni|ingress|security-tools"
    exit 1
fi