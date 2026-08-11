#!/bin/bash
# ==========================================
# teste_setup.sh — valida o setup do zero:
#   1. builda a imagem Docker
#   2. confirma que quartus_sh e vsim funcionam
#   3. compila e simula o exemplo and_gate automaticamente
#
# NÃO testa a gravação na placa (precisa da DE1 conectada
# fisicamente) — isso continua manual, com ./run_quartus.sh
# ==========================================
set -e

IMAGE_NAME="quartus13-cli:latest"

echo "=== [1/3] Build da imagem ==="
docker build -t "$IMAGE_NAME" .

echo ""
echo "=== [2/3] Testando ferramentas dentro do container ==="
docker run --rm "$IMAGE_NAME" bash -c "
  source /etc/profile.d/quartus.sh
  echo '--- quartus_sh ---'
  quartus_sh --version
  echo '--- vsim ---'
  vsim -c -version
"

echo ""
echo "=== [3/3] Compilando e simulando o exemplo and_gate ==="
docker run --rm -v "$(pwd)/projetos:/home/student/projetos" "$IMAGE_NAME" bash -c "
  set -e
  source /etc/profile.d/quartus.sh
  cd and_gate
  rm -rf output_files db incremental_db *.qws work transcript and_gate.vcd
  quartus_sh -t compile.tcl
  test -f output_files/and_gate.sof && echo 'OK: and_gate.sof gerado'
  vsim -c -do sim.do
  test -f and_gate.vcd && echo 'OK: and_gate.vcd gerado'
"

echo ""
echo "=================================================="
echo "Setup validado com sucesso."
echo "Para gravar na placa de verdade (DE1 conectada via USB):"
echo "  ./run_quartus.sh"
echo "=================================================="
