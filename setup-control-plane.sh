#!/bin/bash

# Initialize Kubernetes control plane with Calico network plugin
sudo kubeadm init --pod-network-cidr=192.168.16.0/24

# Save the kubeadm join command for worker nodes
kubeadm token create --print-join-command > /tmp/kubeadm_join_cmd.sh
echo "Run the following on worker nodes to join the cluster:"
cat /tmp/kubeadm_join_cmd.sh

# Set up kubeconfig for kubectl
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Install Kubernetes Network Plugin Calico CNI 
#sudo -u $USER kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/calico.yaml

# Output success message
kubectl get pods -n kube-system
kubectl get nodes
echo "✅ Kubernetes control plane setup complete!"
