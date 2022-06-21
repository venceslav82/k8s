#!/bin/bash

echo "* Add hosts ..."
echo "192.168.56.211 node-1.k8s node-1" >> /etc/hosts
echo "192.168.56.212 node-2.k8s node-2" >> /etc/hosts
echo "192.168.56.213 node-3.k8s node-3" >> /etc/hosts

echo "* Install Additional Packages ..."
sudo apt-get install -y tree git nano



echo "Load br_netfilter module "
sudo modprobe br_netfilter 

echo "Then prepare a configuration file to load it on boot"
sudo cat << EOF |sudo tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF

echo "Adjust a few more network-related settings"
sudo cat << EOF |sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF

echo "And then apply them"
sudo sysctl --system

echo "As a final general step, turn off the SWAP both for the session and in general"
sudo swapoff -a
sudo sed -i '/swap/ s/^/#/' /etc/fstab

echo "Update the repositories information"
sudo apt-get update

echo "And install the required packages"
sudo apt-get install -y ca-certificates curl gnupg lsb-release

echo "Download and install the key"
sudo curl -fsSL https://download.docker.com/linux/debian/gpg |sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo "Add the repository"
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" |sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

echo "Install the required packages"
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

sudo mkdir /etc/docker
sudo cat <<EOF |sudo tee /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF

sudo systemctl enable docker
sudo systemctl daemon-reload
sudo systemctl restart docker

echo "******************************K U B E R N E T E S****************************"
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl
sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" |sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-cache madison kubelet
#sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-get install -y kubelet=1.23.3-00 kubeadm=1.23.3-00 kubectl=1.23.3-00
sudo apt-mark hold kubelet kubeadm kubectl



