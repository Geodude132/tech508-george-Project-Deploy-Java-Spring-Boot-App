#!/bin/bash
# Cloud-init User Data script to deploy Spring Boot app and MySQL via Minikube on a fresh VM

# Log everything
exec > >(tee -a /var/log/k8s-setup.log)
exec 2>&1

echo "=== Starting Kubernetes deployment at $(date) ==="

# Update packages and install dependencies
apt update -y
apt install -y docker.io git conntrack curl build-essential

# Enable and start Docker
systemctl enable docker
systemctl start docker
usermod -aG docker ubuntu

# Refresh Docker group membership for current session
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
docker volume prune -f || true

# Delete any existing Minikube cluster
sudo -u ubuntu minikube delete || true

# Clone or update project repository
cd /home/ubuntu
if [ -d "ProjectLibrary2" ]; then
    sudo -u ubuntu git -C ProjectLibrary2 pull
else
    sudo -u ubuntu git clone https://github.com/Geodude132/tech508-george-Project-Deploy-Java-Spring-Boot-App.git ProjectLibrary2
fi
chown -R ubuntu:ubuntu ProjectLibrary2

# Verify Kubernetes manifest files exist
for f in mysql-deployment.yaml app-deployment.yaml; do
    if [ ! -f "/home/ubuntu/ProjectLibrary2/LibraryProject2/k8s/$f" ]; then
        echo "ERROR: $f not found!"
        exit 1
    fi
done

# Determine available disk space for Minikube (~70%, min 20GB)
AVAILABLE_DISK=$(df --output=avail / | tail -1)
DISK_SIZE_MB=$((AVAILABLE_DISK * 70 / 1000))
[ $DISK_SIZE_MB -lt 20000 ] && DISK_SIZE_MB=20000
DISK_SIZE="${DISK_SIZE_MB}mb"

# Start Minikube with sufficient resources
sudo -u ubuntu minikube start \
  --driver=docker \
  --cpus=2 \
  --memory=3072 \
  --disk-size=$DISK_SIZE \
  --wait=all

# Configure Docker to use Minikube environment
eval $(sudo -u ubuntu minikube docker-env)

# Build Docker image inside Minikube
sudo -u ubuntu docker build -f /home/ubuntu/ProjectLibrary2/LibraryProject2/app.dockerfile \
  -t projectlibrary2-app:latest /home/ubuntu/ProjectLibrary2/LibraryProject2

# Deploy MySQL
sudo -u ubuntu kubectl apply -f /home/ubuntu/ProjectLibrary2/LibraryProject2/k8s/mysql-deployment.yaml

# Wait for MySQL pod to be ready
sudo -u ubuntu kubectl wait --for=condition=ready pod -l app=mysql --timeout=600s

# Deploy Spring Boot application
sudo -u ubuntu kubectl apply -f /home/ubuntu/ProjectLibrary2/LibraryProject2/k8s/app-deployment.yaml

# Ensure the app deployment uses the latest image
sudo -u ubuntu kubectl rollout restart deployment/library-app

# Patch the NodePort service to use a valid port (e.g., 30500)
sudo -u ubuntu kubectl patch svc library-service -p '{"spec":{"ports":[{"port":8080,"targetPort":8080,"nodePort":30500}],"type":"NodePort"}}'

echo "=== Kubernetes deployment finished at $(date) ==="
echo "You can access the Spring Boot app at: http://<VM_PUBLIC_IP>:30500"
