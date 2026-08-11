#!/bin/bash
# ==========================================
# Roda o container CLI-only do Quartus II 13.0sp1
# com acesso ao USB-Blaster local, e a pasta de
# projetos montada.
# ==========================================
set -e

IMAGE_NAME="quartus13-cli:latest"
PROJETOS_DIR="$(pwd)/projetos"

mkdir -p "$PROJETOS_DIR"

docker run -it --rm \
  --name quartus13_cli \
  --device-cgroup-rule='c 189:* rmw' \
  -v /dev/bus/usb:/dev/bus/usb \
  -v "$PROJETOS_DIR:/home/student/projetos" \
  "$IMAGE_NAME" \
  bash -c "source /etc/profile.d/quartus.sh && bash"
