#!/bin/bash
# ==========================================
# registry_setup.sh — roda UMA VEZ, no servidor UFT.
# Sobe um registry Docker privado (com autenticação),
# pra distribuir a imagem quartus13-cli pros alunos
# sem depender do Docker Hub.
# ==========================================
set -e

REGISTRY_DIR="$HOME/registry"
mkdir -p "$REGISTRY_DIR/auth" "$REGISTRY_DIR/data"

if [ ! -f "$REGISTRY_DIR/auth/htpasswd" ]; then
  echo "Defina um usuário e senha para os alunos usarem no 'docker login':"
  read -p "Usuário: " REG_USER
  read -s -p "Senha: " REG_PASS
  echo ""
  docker run --rm --entrypoint htpasswd httpd:2 -Bbn "$REG_USER" "$REG_PASS" \
    > "$REGISTRY_DIR/auth/htpasswd"
  echo "Credenciais salvas em $REGISTRY_DIR/auth/htpasswd (não versionar, não commitar)."
fi

docker run -d \
  --restart=always \
  --name quartus_registry \
  -v "$REGISTRY_DIR/auth":/auth \
  -v "$REGISTRY_DIR/data":/var/lib/registry \
  -e REGISTRY_AUTH=htpasswd \
  -e REGISTRY_AUTH_HTPASSWD_REALM="UFT Quartus Registry" \
  -e REGISTRY_AUTH_HTPASSWD_PATH=/auth/htpasswd \
  -p 5000:5000 \
  registry:2

echo ""
echo "=================================================="
echo "Registry rodando em 172.16.13.190:5000"
echo ""
echo "Pra publicar a imagem (rodar aqui no servidor, ou em"
echo "qualquer máquina que já tenha buildado a imagem):"
echo "  docker tag quartus13-cli:latest 172.16.13.190:5000/quartus13-cli:latest"
echo "  docker login 172.16.13.190:5000"
echo "  docker push 172.16.13.190:5000/quartus13-cli:latest"
echo "=================================================="
