#!/bin/bash
set -e
exec > /var/log/user-data.log 2>&1  # log everything for debugging

# Install Docker from official repo
apt-get update -y
apt-get install -y ca-certificates curl gnupg unzip python3

install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
  | tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

systemctl start docker
systemctl enable docker

# Install AWS CLI v2
curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o /tmp/awscliv2.zip
unzip -q /tmp/awscliv2.zip -d /tmp
/tmp/aws/install

# Pull secrets from Secrets Manager
SECRETS=$(aws secretsmanager get-secret-value \
  --secret-id "library-system/dev" \
  --region ${region} \
  --query SecretString \
  --output text)

MONGO_URI=$(echo $SECRETS | python3 -c "import sys,json; print(json.load(sys.stdin)['MONGO_URI'])")
JWT_SECRET=$(echo $SECRETS | python3 -c "import sys,json; print(json.load(sys.stdin)['JWT_SECRET'])")

# Validate secrets were actually fetched
if [ -z "$MONGO_URI" ] || [ -z "$JWT_SECRET" ]; then
  echo "ERROR: Failed to fetch secrets from Secrets Manager"
  exit 1
fi

# Authenticate Docker to ECR
REGISTRY=$(echo "${backend_image_uri}" | cut -d'/' -f1)
aws ecr get-login-password --region ${region} | docker login --username AWS --password-stdin $REGISTRY

# Create .env file for docker-compose
cat <<EOF > /home/ubuntu/.env
MONGO_URI=$MONGO_URI
JWT_SECRET=$JWT_SECRET
NODE_ENV=production
PORT=5000
EOF

chmod 600 /home/ubuntu/.env
chown ubuntu:ubuntu /home/ubuntu/.env

# Create docker-compose.yml
cat <<EOF > /home/ubuntu/docker-compose.yml
version: '3.8'
services:
  backend:
    image: ${backend_image_uri}
    restart: unless-stopped
    ports:
      - "5000:5000"
    env_file:
      - /home/ubuntu/.env
    healthcheck:
      test: ["CMD", "wget", "--no-verbose", "--tries=1", "--spider", "http://localhost:5000/api/auth/login"]
      interval: 30s
      timeout: 10s
      retries: 5
      start_period: 60s

  frontend:
    image: ${frontend_image_uri}
    restart: unless-stopped
    ports:
      - "80:80"
    depends_on:
      - backend
EOF

chown ubuntu:ubuntu /home/ubuntu/docker-compose.yml

cd /home/ubuntu
docker compose up -d
