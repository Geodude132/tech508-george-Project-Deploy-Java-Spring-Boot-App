#!/bin/bash
# Cloud-init User Data script to deploy Spring Boot app + MySQL via Minikube

exec > >(tee -a /var/log/k8s-setup.log)
exec 2>&1

echo "=== Starting Kubernetes deployment at $(date) ==="

# Install dependencies
apt update -y
apt install -y docker.io git conntrack curl build-essential

# Enable/start Docker and add ubuntu to docker group
systemctl enable docker
systemctl start docker
usermod -aG docker ubuntu
sleep 5

# Verify Docker works for ubuntu
sudo -u ubuntu docker ps || { echo "ERROR: Docker not accessible by ubuntu user"; exit 1; }

# Install kubectl
KUBECTL_VERSION="v1.29.6"
curl -Lo /usr/local/bin/kubectl "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"
chmod +x /usr/local/bin/kubectl

# Install Minikube
curl -Lo /usr/local/bin/minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
chmod +x /usr/local/bin/minikube

# Cleanup Docker
docker system prune -af || true
docker volume prune -f || true

# Delete any existing Minikube cluster
sudo -u ubuntu minikube delete || true

# Clone or update repo
cd /home/ubuntu
if [ -d "ProjectLibrary2" ]; then
    sudo -u ubuntu git -C ProjectLibrary2 pull
else
    sudo -u ubuntu git clone https://github.com/Geodude132/tech508-george-Project-Deploy-Java-Spring-Boot-App.git ProjectLibrary2
fi
chown -R ubuntu:ubuntu ProjectLibrary2

# Check manifest files
for f in mysql-deployment.yaml app-deployment.yaml; do
  [ ! -f "/home/ubuntu/ProjectLibrary2/LibraryProject2/k8s/$f" ] && { echo "ERROR: $f not found"; exit 1; }
done

# Start Minikube
AVAILABLE_DISK=$(df --output=avail / | tail -1)
DISK_SIZE_MB=$((AVAILABLE_DISK * 70 / 1000))
[ $DISK_SIZE_MB -lt 20000 ] && DISK_SIZE_MB=20000
DISK_SIZE="${DISK_SIZE_MB}mb"

sudo -u ubuntu minikube start \
  --driver=docker \
  --cpus=2 \
  --memory=3072 \
  --disk-size=$DISK_SIZE \
  --wait=all

# Use Minikube Docker
eval $(sudo -u ubuntu minikube docker-env)

# Build app Docker image
sudo -u ubuntu docker build -f /home/ubuntu/ProjectLibrary2/LibraryProject2/app.dockerfile \
  -t projectlibrary2-app:latest /home/ubuntu/ProjectLibrary2/LibraryProject2

# Deploy MySQL and wait
sudo -u ubuntu kubectl apply -f /home/ubuntu/ProjectLibrary2/LibraryProject2/k8s/mysql-deployment.yaml
sudo -u ubuntu kubectl wait --for=condition=ready pod -l app=mysql --timeout=600s

# Deploy Spring Boot app
sudo -u ubuntu kubectl apply -f /home/ubuntu/ProjectLibrary2/LibraryProject2/k8s/app-deployment.yaml
sudo -u ubuntu kubectl rollout restart deployment/library-app

echo "=== Deployment finished at $(date) ==="
echo "Access the Spring Boot app at: http://<VM_PUBLIC_IP>:30500"
