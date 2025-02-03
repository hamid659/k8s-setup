#!/bin/bash

# Disable swap
sudo swapoff -a
sudo sed -i '/ swap / s/^/#/' /etc/fstab

# Load necessary kernel modules
sudo modprobe overlay
sudo modprobe br_netfilter

# Enable required sysctl settings
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF
sudo sysctl --system

# Update the system
sudo apt update && sudo apt upgrade -y

# Install containerd
sudo apt install -y containerd

# Configure containerd
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
sudo systemctl restart containerd
sudo systemctl enable containerd

# Install dependencies for Kubernetes APT repository
sudo apt install -y curl apt-transport-https ca-certificates

# Add the official Kubernetes APT repository
curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
sudo sh -c 'echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list'

# Update package list after adding Kubernetes repository
sudo apt update

# Install Kubernetes components (kubelet, kubeadm, kubectl)
sudo apt install -y kubelet kubeadm kubectl

# Mark the Kubernetes packages to hold (to prevent automatic updates)
sudo apt-mark hold kubelet kubeadm kubectl

# Enable kubelet
sudo systemctl enable --now kubelet

# Initialize Kubernetes control plane with Calico network plugin
sudo kubeadm init --pod-network-cidr=192.168.16.0/24

# Set up kubeconfig for kubectl
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Apply Calico CNI plugin
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml

# Output
echo "Control plane setup complete!"