#!/bin/bash
set -e

# Update system
apt-get update -y
apt-get install -y docker.io awscli docker-compose-plugin

systemctl start docker
systemctl enable docker

# Add ubuntu user to docker group
usermod -aG docker ubuntu || true

# Variables from Terraform
REGISTRY=$(echo "${backend_image_uri}" | cut -d'/' -f1)

# Authenticate Docker to ECR
aws ecr get-login-password --region ${region} | docker login --username AWS --password-stdin $REGISTRY

# Create docker-compose.yml
cat <<EOF > /home/ubuntu/docker-compose.yml
version: '3.8'
services:
  backend:
    image: ${backend_image_uri}
    restart: unless-stopped
    ports:
      - "5000:5000"
    # environment:
    #   - MONGO_URI=mongodb://your-db-string

  frontend:
    image: ${frontend_image_uri}
    restart: unless-stopped
    ports:
      - "80:80"
    depends_on:
      - backend
EOF

# Change ownership to ubuntu user
chown ubuntu:ubuntu /home/ubuntu/docker-compose.yml

# Run containers
cd /home/ubuntu
docker compose up -d