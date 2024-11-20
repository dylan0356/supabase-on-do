#!/bin/bash

set -e  # Exit on any error

# A Bash script to install Docker and Docker Compose on Ubuntu 22

# Ensure debconf is set to noninteractive to avoid prompts
echo "Setting debconf to noninteractive..."
export DEBIAN_FRONTEND=noninteractive
echo 'debconf debconf/frontend select Noninteractive' | sudo debconf-set-selections

# Fix potential lock issues
function wait_for_lock() {
  local lock_file="$1"
  echo "Waiting for lock on $lock_file..."
  while sudo lsof "$lock_file" >/dev/null 2>&1; do
    sleep 10
  done
}

# Update existing packages
echo "Updating package lists..."
wait_for_lock "/var/lib/dpkg/lock-frontend"
sudo apt-get -y update

# Install required dependencies
echo "Installing prerequisites..."
wait_for_lock "/var/lib/dpkg/lock-frontend"
sudo apt-get -y install ca-certificates curl gnupg lsb-release

# Add the GPG key for Docker
echo "Adding Docker GPG key..."
sudo mkdir -m 0755 -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Add the Docker repository to APT sources
echo "Adding Docker repository..."
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update package lists again
echo "Updating package lists for Docker..."
wait_for_lock "/var/lib/dpkg/lock-frontend"
sudo apt-get -y update

# Install Docker and related packages
echo "Installing Docker..."
wait_for_lock "/var/lib/dpkg/lock-frontend"
sudo apt-get -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Test Docker installation
echo "Testing Docker installation..."
docker --version

# Test Docker Compose
echo "Testing Docker Compose..."
docker compose version

echo "Docker and Docker Compose installed successfully!"
