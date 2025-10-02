#!/bin/bash
set -euo pipefail

apt update -y && apt upgrade -y
apt install -y curl apt-transport-https docker.io conntrack git

# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo install kubectl /usr/local/bin/kubectl

# Install Minikube
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
chmod +x minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube

# Ensure /usr/local/bin is in PATH
export PATH=$PATH:/usr/local/bin

# Clone repo
cd /home/ubuntu
if [ ! -d ProjectLibrary2 ]; then
  git clone https://github.com/Geodude132/tech508-george-Project-Deploy-Java-Spring-Boot-App.git ProjectLibrary2
fi
cd ProjectLibrary2/k8s

# Start Minikube
sudo minikube start --driver=docker --force

# Wait for Minikube to be ready
sudo kubectl wait --for=condition=ready pod --all --timeout=180s || true

# Apply manifests
sudo kubectl apply -f mysql-deployment.yaml
sudo kubectl apply -f app-deployment.yaml
sudo kubectl apply -f app-service.yaml
