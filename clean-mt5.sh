#!/bin/bash
echo "🧹 Cleaning MT5 environment..."

docker-compose stop mt5
docker-compose rm -f mt5
docker volume rm zanalytics-platform_mt5-config 2>/dev/null || true
rm -rf ./mt5-config 2>/dev/null || true

echo "✅ MT5 environment cleaned!"
echo "Run 'docker-compose up -d mt5' to start fresh"