#!/bin/bash

# Join the worker node to the cluster (Replace with actual command from control plane)
# Use the token and hash from the control plane
echo "To join this node to the cluster, run the following command on this worker node:"
echo "kubeadm join <CONTROL_PLANE_IP>:6443 --token <TOKEN> --discovery-token-ca-cert-hash sha256:<HASH>"

# Output
echo "Worker node setup complete!"