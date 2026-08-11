# Quartus II 13.0sp1 em Docker — DE1 (Cyclone II)

Ambiente Docker, somente CLI (sem GUI), para compilar, simular e gravar
projetos VHDL na placa Terasic DE1 (Cyclone II EP2C20F484C7) usando
Quartus II 13.0sp1 Web Edition + ModelSim.

A imagem roda em Ubuntu 20.04 (base do container) e funciona em qualquer
host Linux com Docker, independente da versão do Ubuntu do host (testado
com host Ubuntu 22.04).

## Pré-requisitos: baixar os instaladores (não incluídos neste repositório)

Os instaladores da Intel/Altera são grandes e proprietários — não podem
ser redistribuídos aqui. Baixe manualmente em:

https://www.altera.com/downloads/fpga-development-tools/quartus-ii-web-edition-design-software-version-13-0sp1-linux

Baixe estes três arquivos e coloque na **raiz deste repositório** (mesmo
nível do `Dockerfile`):

- `QuartusSetupWeb-13.0.1.232.run` (Quartus II Software) — 1.6 GB
- `cyclone_web-13.0.1.232.qdz` (Cyclone II/III/IV Device Support) — 569 MB
- `ModelSimSetup-13.1.0.162.run` (ModelSim-Edition) — ~776 MB

## Setup (uma vez por máquina)

```bash
sudo bash install_docker.sh              # instala o Docker
sudo bash install_usb_blaster_udev.sh    # permissão USB para o USB-Blaster
docker build -t quartus13-cli:latest .   # builda a imagem (demorado na 1a vez)
```

O build demora bastante na primeira vez — o instalador do Quartus trava
ao final mesmo já tendo terminado (bug conhecido dessa versão), então o
Dockerfile usa um timeout de 30 min por instalador antes de seguir em
frente. Rebuilds seguintes reaproveitam cache e são rápidos.

## Uso (toda sessão)

Com a placa DE1 conectada via USB:

```bash
./run_quartus.sh
```

Isso abre um shell dentro do container, com a pasta `projetos/` do host
montada em `~/projetos` (usada pra persistir os arquivos entre sessões,
já que o container é descartável — o exemplo `and_gate` já vem dentro
dela, e seus próprios projetos podem ficar em pastas irmãs, ex:
`projetos/meu_projeto/`).

## Fluxo de um projeto

Dentro do container:

```bash
cd projetos/and_gate          # ou sua pasta de projeto
quartus_sh -t compile.tcl     # compila -> gera output_files/*.sof
vsim -c -do sim.do            # simula -> gera *.vcd
jtagconfig                    # confirma que a DE1 está visível
quartus_pgm -c "USB-Blaster" -m jtag -o "p;output_files/and_gate.sof"
```

Pra visualizar a forma de onda gerada (`.vcd`), veja a seção
"Visualizando a simulação (GTKWave)" abaixo.

## Visualizando a simulação (GTKWave)

O `vsim -c -do sim.do` gera um arquivo `.vcd` (Value Change Dump) — um
formato de forma de onda padrão e em texto, aberto por qualquer
visualizador. Recomendamos o **GTKWave**: leve, moderno, sem nenhum dos
problemas de renderização que a GUI antiga do Quartus/ModelSim tem.

**Instalação (uma vez, na máquina local — fora do container):**

```bash
sudo apt install gtkwave
```

**Uso, depois de rodar a simulação:**

```bash
gtkwave projetos/and_gate/and_gate.vcd
```

Dentro do GTKWave:

1. No painel esquerdo (SST), clique na hierarquia do design
   (`tb_and_gate` → `uut`) pra ver os sinais disponíveis no painel do
   meio.
2. Selecione os sinais que quer ver (`sw0`, `sw1`, `ledr0`) e clique em
   **Insert** (ou arraste) pro painel de ondas à direita.
3. Use os ícones de zoom na barra de ferramentas (ou `Ctrl` + scroll do
   mouse) pra ajustar a escala de tempo e ver as 4 combinações de
   `SW0`/`SW1` que o testbench percorre.

## Exemplo incluído: `projetos/and_gate/`

Porta AND simples — `SW0` e `SW1` como entradas, `LEDR0` como saída.
Pinos já mapeados pra DE1 (Cyclone II EP2C20F484C7):

| Sinal | Pino |
|---|---|
| SW0 | PIN_L22 |
| SW1 | PIN_L21 |
| LEDR0 | PIN_R20 |

- `and_gate.vhd` — o design
- `tb_and_gate.vhd` — testbench
- `compile.tcl` — script de compilação (quartus_sh)
- `sim.do` — script de simulação (ModelSim, gera `.vcd`)

## Por que essa versão do Quartus?

Quartus **Prime** (14.0+) não suporta mais a família Cyclone II — a
última versão com suporte é o Quartus **II** 13.0sp1. Se você tem uma
DE1-SoC (Cyclone V) em vez da DE1 clássica (Cyclone II), pode usar
Quartus Prime normalmente e não precisa deste setup.

## Por que CLI e não GUI?

A GUI do Quartus 13.0sp1/17.1 é Java Swing antigo e, rodando dentro de
container (via X11 forwarding ou VNC), esbarra em uma cadeia de bugs de
renderização (tela em branco, travamentos) sem solução estável. As
ferramentas de linha de comando (`quartus_sh`, `quartus_map`,
`quartus_fit`, `quartus_asm`, `quartus_pgm`, `vsim`) não têm esse
problema — mesmo fluxo de compilação/simulação/gravação, sem GUI.
