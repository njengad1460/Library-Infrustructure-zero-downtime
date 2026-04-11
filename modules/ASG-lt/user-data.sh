#!/bin/bash
sudo apt-get update -y
sudo apt-get install -y docker.io
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ubuntu

# Run a sample app (nginx) to represent the library management system
docker run -d -p 80:80 --name library-app nginx
