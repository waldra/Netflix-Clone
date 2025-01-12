#!/bin/bash

#=========== Docker Installation ==============
# Add Docker's official GPG key:
apt update && apt install ca-certificates curl
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
apt update && apt install -y docker.io

# Configure docker as non-root user
usermod -aG docker ubuntu
newgrp docker
docker image pull sonarqube:lts-community
docker container run -d --name=sonarqube -p 9000:9000 sonarqube:lts-community