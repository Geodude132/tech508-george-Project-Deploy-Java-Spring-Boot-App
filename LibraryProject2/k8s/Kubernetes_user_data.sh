#!/bin/bash
# Cloud-init User Data script to deploy Spring Boot app and MySQL via Minikube

# Log everything
exec > >(tee -a /var/log/k8s-setup.log)
exec 2>&1

echo "=== Starting Kubernetes deployment at $(date) ==="

# Update and install dependencies
apt update -y
apt install -y docker.io git conntrack curl build-essential

# Enable Docker for ubuntu user
systemctl enable docker
systemctl start docker
usermod -aG docker ubuntu

# Refresh Docker group membership
newgrp docker <<'EOF'
echo "=== Docker group refreshed ==="
EOF

# Install kubectl
KUBECTL_VERSION="v1.29.6"
curl -Lo /usr/local/bin/kubectl "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"
chmod +x /usr/local/bin/kubectl

# Install Minikube
curl -Lo /usr/local/bin/minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
chmod +x /usr/local/bin/minikube

# Clean up Docker to free space
docker system prune -af || true

# Remove any existing Minikube cluster
sudo -u ubuntu minikube delete || true

# Clone or update repository
cd /home/ubuntu
if [ -d "ProjectLibrary2" ]; then
    sudo -u ubuntu git -C ProjectLibrary2 pull
else
    sudo -u ubuntu git clone https://github.com/Geodude132/tech508-george-Project-Deploy-Java-Spring-Boot-App.git ProjectLibrary2
fi
chown -R ubuntu:ubuntu ProjectLibrary2

# Verify k8s manifest files exist
for f in mysql-deployment.yaml app-deployment.yaml; do
    if [ ! -f "/home/ubuntu/ProjectLibrary2/LibraryProject2/k8s/$f" ]; then
        echo "ERROR: $f not found!"
        exit 1
    fi
done

# Start Minikube with safe memory for VM (~3GB)
sudo -u ubuntu minikube start --driver=docker --cpus=2 --memory=3072 --disk-size=20g --wait=all

# Configure Docker to use Minikube environment
eval $(sudo -u ubuntu minikube docker-env)

# Build Docker image inside Minikube using app.dockerfile
sudo -u ubuntu docker build -f /home/ubuntu/ProjectLibrary2/LibraryProject2/app.dockerfile -t projectlibrary2-app:latest /home/ubuntu/ProjectLibrary2/LibraryProject2

# Deploy MySQL
sudo -u ubuntu kubectl apply -f /home/ubuntu/ProjectLibrary2/LibraryProject2/k8s/mysql-deployment.yaml

# Wait for MySQL pod to be ready (timeout 2 minutes)
sudo -u ubuntu kubectl wait --for=condition=ready pod -l app=mysql --timeout=120s

# Deploy Spring Boot application
sudo -u ubuntu kubectl apply -f /home/ubuntu/ProjectLibrary2/LibraryProject2/k8s/app-deployment.yaml

# Ensure the app deployment uses the latest image
sudo -u ubuntu kubectl rollout restart deployment/library-app

# Optional: forward port 8080 in the background so you can access it from the VM
sudo -u ubuntu kubectl port-forward svc/library-service 8080:8080 &

echo "=== Kubernetes deployment finished at $(date) ==="
