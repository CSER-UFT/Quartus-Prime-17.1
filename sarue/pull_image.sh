#!/bin/bash
# ==========================================
# pull_image.sh — baixa a imagem pronta do registry
# da UFT, em vez de buildar do zero (pula os 3
# downloads da Intel e o build de 30-60min).
# ==========================================
set -e

if [ -z "$1" ]; then
  echo "Uso: bash pull_image.sh <IP_DO_SERVIDOR>:5000"
  exit 1
fi

REGISTRY="$1"

docker login "$REGISTRY"
docker pull "$REGISTRY/quartus13-cli:latest"
docker tag "$REGISTRY/quartus13-cli:latest" quartus13-cli:latest

echo "Pronto. Use ./run_quartus.sh normalmente."
