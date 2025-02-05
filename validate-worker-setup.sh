#!/bin/bash

echo "Validating Kubernetes Worker Node..."

# Check if swap is disabled
if free | awk '/Swap/{exit !$2}'; then
  echo "❌ Swap is enabled. Disable it using: sudo swapoff -a"
  exit 1
else
  echo "✅ Swap is disabled."
fi

# Check if required kernel modules are loaded
for module in overlay br_netfilter; do
  if ! lsmod | grep -q $module; then
    echo "❌ Kernel module $module is not loaded. Load it using: sudo modprobe $module"
    exit 1
  else
    echo "✅ Kernel module $module is loaded."
  fi
done

# Check required sysctl settings
SYSCTL_CONF="/etc/sysctl.d/k8s.conf"
if [[ ! -f "$SYSCTL_CONF" ]] || ! grep -q 'net.ipv4.ip_forward = 1' "$SYSCTL_CONF"; then
  echo "❌ Required sysctl settings are missing. Apply them using:"
  echo "echo -e 'net.bridge.bridge-nf-call-iptables=1\nnet.bridge.bridge-nf-call-ip6tables=1\nnet.ipv4.ip_forward=1' | sudo tee $SYSCTL_CONF"
  exit 1
else
  echo "✅ Sysctl settings are correctly configured."
fi

# Check if containerd is running
if ! systemctl is-active --quiet containerd; then
  echo "❌ containerd is not running. Start it using: sudo systemctl start containerd"
  exit 1
else
  echo "✅ containerd is running."
fi

# Check if kubelet is installed
if ! command -v kubelet &>/dev/null; then
  echo "❌ kubelet is not installed. Install it using: sudo apt install -y kubelet"
  exit 1
else
  echo "✅ kubelet is installed."
fi

# Check if conntrack is installed
if ! command -v conntrack &>/dev/null; then
  echo "❌ conntrack is missing. Install it using: sudo apt install -y conntrack"
  exit 1
else
  echo "✅ conntrack is installed."
fi

echo "🎉 Worker node validation PASSED. Ready to join the control plane!"
