#!/bin/bash
set -euo pipefail

# Update system
apt update && apt upgrade -y

# Install dependencies
apt install -y ca-certificates curl gnupg lsb-release git

# Install Docker
mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
apt update -y
apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Add ubuntu user to Docker group (so docker commands can run without sudo)
usermod -aG docker ubuntu || true

# Clone project repo if it doesn't exist
cd /home/ubuntu
if [ ! -d ProjectLibrary2 ]; then
  git clone https://github.com/Geodude132/tech508-george-Project-Deploy-Java-Spring-Boot-App.git ProjectLibrary2
fi

# Fix ownership so ubuntu user can access files
chown -R ubuntu:ubuntu ProjectLibrary2

# Navigate to project directory
cd /home/ubuntu/ProjectLibrary2

# Build and start Docker Compose stack
docker compose build
docker compose up -d

# Enable Docker Compose stack to start on VM reboot
cat << 'EOF' > /etc/systemd/system/projectlibrary2.service
[Unit]
Description=ProjectLibrary2 Docker Compose Service
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
WorkingDirectory=/home/ubuntu/ProjectLibrary2
ExecStart=/usr/bin/docker compose up -d
ExecStop=/usr/bin/docker compose down
RemainAfterExit=yes
User=ubuntu
Group=ubuntu

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd and enable the service
systemctl daemon-reload
systemctl enable projectlibrary2.service
systemctl start projectlibrary2.service

# Optional: wait a few seconds and show container status
sleep 10
docker ps -a

# Optional: test the app
echo "Testing app on port 8080..."
curl --retry 5 --retry-connrefused http://localhost:8080 || echo "App not responding yet."
