#!/bin/bash
# Update and install Docker
sudo apt-get update -y
sudo apt-get install -y docker.io unzip
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ubuntu

# Install AWS CLI (needed for ECR login)
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Extract registry from image URI
REGISTRY=$(echo "${ecr_image_uri}" | cut -d'/' -f1)

# Login to ECR
# The IAM instance profile provides the necessary permissions
aws ecr get-login-password --region "${region}" | docker login --username AWS --password-stdin "$REGISTRY"

# Pull and run the container
docker pull "${ecr_image_uri}"
docker run -d -p 80:80 --name library-app "${ecr_image_uri}"
