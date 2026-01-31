#!/bin/bash

# ==========================================
# Script de instalação Docker Engine
# Ubuntu 20.04 LTS
# ==========================================

set -e  # para parar em caso de erro

echo "Atualizando pacotes do sistema..."
sudo apt-get update -y
sudo apt-get upgrade -y

echo "Removendo versões antigas do Docker..."
sudo apt-get remove -y docker docker-engine docker.io containerd runc || true

echo "Instalando dependências..."
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

echo "Adicionando chave GPG oficial do Docker..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo "Adicionando repositório oficial do Docker..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] \
  https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

echo "Atualizando pacotes novamente..."
sudo apt-get update -y

echo "Instalando Docker Engine, CLI e containerd..."
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

echo "Habilitando e iniciando o serviço Docker..."
sudo systemctl enable docker
sudo systemctl start docker

echo "Adicionando usuário atual ao grupo docker (permite rodar sem sudo)..."
sudo usermod -aG docker $USER

echo "Verificando instalação..."
docker --version
docker run hello-world

echo "========================================"
echo "Docker Engine instalado com sucesso!"
echo "OBS: você precisa sair e entrar novamente na sessão para usar Docker sem sudo."
echo "========================================"
