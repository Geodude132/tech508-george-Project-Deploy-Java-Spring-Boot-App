#!/bin/bash
set -euo pipefail

# Update system
apt update -y && apt upgrade -y

# Install dependencies
apt install -y curl apt-transport-https docker.io conntrack git

# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Install Minikube
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
install minikube-linux-amd64 /usr/local/bin/minikube

# Clone repo
cd /home/ubuntu
git clone https://github.com/Geodude132/tech508-george-Project-Deploy-Java-Spring-Boot-App.git ProjectLibrary2
cd ProjectLibrary2/k8s

# Start Minikube (with Docker driver)
minikube start --driver=docker --force

# Wait a bit for Minikube to stabilise
sleep 60

# Apply Kubernetes manifests
kubectl apply -f mysql-deployment.yaml
kubectl apply -f app-deployment.yaml
kubectl apply -f app-service.yaml
