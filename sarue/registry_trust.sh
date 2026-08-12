#!/bin/bash
# ==========================================
# registry_trust.sh — roda UMA VEZ por máquina do
# laboratório (precisa de sudo). Configura o Docker
# pra confiar no registry interno da UFT (HTTP, sem
# TLS — aceitável numa rede interna do campus, não
# exposta à internet).
# ==========================================
set -e

if [ -z "$1" ]; then
  echo "Uso: sudo bash registry_trust.sh <IP_DO_SERVIDOR>:5000"
  exit 1
fi

REGISTRY="$1"
CONFIG_FILE="/etc/docker/daemon.json"

if [ -f "$CONFIG_FILE" ]; then
  echo "Aviso: $CONFIG_FILE já existe — não sobrescrevendo."
  echo "Adicione manualmente esta chave dentro do JSON existente:"
  echo "  \"insecure-registries\": [\"$REGISTRY\"]"
  echo "e rode: sudo systemctl restart docker"
  exit 1
fi

cat > "$CONFIG_FILE" << JSON
{
  "insecure-registries": ["$REGISTRY"]
}
JSON

systemctl restart docker
echo "Docker configurado para confiar em $REGISTRY"
