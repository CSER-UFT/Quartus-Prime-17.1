#!/bin/bash
# ==========================================
# Configura a permissão do USB-Blaster no HOST.
#
# IMPORTANTE: este script roda na máquina física
# (fora do Docker). Regras udev são aplicadas pelo
# kernel do host — rodar isso dentro do container
# não tem nenhum efeito, pois o container não
# controla o udev do host.
#
# Rode uma única vez por máquina host.
# ==========================================
set -e

RULES_FILE="51-altera-usb-blaster.rules"

if [ ! -f "$RULES_FILE" ]; then
    echo "Arquivo $RULES_FILE não encontrado no diretório atual."
    echo "Rode este script a partir da pasta que contém o arquivo de regras."
    exit 1
fi

echo "Instalando regra udev do USB-Blaster em /etc/udev/rules.d/..."
sudo cp "$RULES_FILE" /etc/udev/rules.d/

echo "Recarregando udev..."
sudo udevadm control --reload
sudo udevadm trigger

echo "========================================"
echo "Regra aplicada com sucesso."
echo "Se a placa DE1 já estiver conectada, desconecte"
echo "e reconecte o cabo USB para que a nova permissão"
echo "seja aplicada ao dispositivo."
echo "========================================"
