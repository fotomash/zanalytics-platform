#!/bin/bash
# Migration script to use the working Docker setup

echo "🔄 Migrating to working MT5 Docker setup..."

# 1. Stop current container
docker-compose stop mt5
docker-compose rm -f mt5

# 2. Clean the config directory
echo "Cleaning config directory..."
sudo rm -rf ./mt5-config
mkdir -p ./mt5-config
sudo chown -R $(id -u):$(id -g) ./mt5-config

# 3. Use the working image tag
echo "Using working base image..."
sed -i 's|FROM .*|FROM ghcr.io/linuxserver/baseimage-kasmvnc:debianbullseye-8446af38-ls104 AS base|' backend/mt5/Dockerfile

# 4. Rebuild
echo "Building MT5 image..."
docker-compose build --no-cache mt5

# 5. Start
echo "Starting MT5 container..."
docker-compose up -d mt5

echo "✅ Migration complete! Check logs with: docker-compose logs -f mt5"
