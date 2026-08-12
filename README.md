# Quartus II 13.0sp1 em Docker — DE1 (Cyclone II)

Ambiente Docker, somente CLI (sem GUI), para compilar, simular e gravar
projetos VHDL na placa Terasic DE1 (Cyclone II EP2C20F484C7) usando
Quartus II 13.0sp1 Web Edition + ModelSim.

A imagem roda em Ubuntu 20.04 (base do container) e funciona em qualquer
host Linux com Docker, independente da versão do Ubuntu do host (testado
com host Ubuntu 22.04).

## Estrutura do repositório

```
.
├── README.md
├── .gitignore
├── install_docker.sh              # usado nos dois casos (máquina local E servidor)
├── install_usb_blaster_udev.sh    # usado independente do caminho (pull ou build)
├── 51-altera-usb-blaster.rules
├── run_quartus.sh                 # usado independente do caminho (pull ou build)
├── projetos/
│   └── and_gate/
├── local/                  # específico de cada caminho (build ou pull)
│   ├── Dockerfile
│   └── teste_setup.sh
└── sarue/                  # só roda no servidor (registry privado)
    ├── registry_setup.sh
    ├── pull_image.sh
    └── registry_trust.sh
```

## Duas formas de usar

Existem dois caminhos independentes — escolha um:

- **Pull (recomendado para alunos)**: baixa a imagem já pronta do
  registry privado hospedado no servidor `sarue` (172.16.13.190). Não
  precisa baixar os instaladores da Intel nem esperar o build (~30-60
  min). É o caminho normal do dia a dia.
- **Build local (para quem for modificar o `Dockerfile`, ou não tiver
  acesso ao registry)**: builda a imagem do zero, a partir dos
  instaladores da Intel/Altera baixados manualmente.

---

## Caminho 1: Pull da imagem pronta (via servidor sarue)

**Uma vez por máquina do laboratório** (precisa de admin/sudo):
```bash
sudo ./install_docker.sh
sudo ./install_usb_blaster_udev.sh
sudo ./sarue/registry_trust.sh 172.16.13.190:5000
```

**Por aluno/sessão:**
```bash
./sarue/pull_image.sh 172.16.13.190:5000   # login + pull + tag local
./run_quartus.sh
```

Peça o usuário/senha de acesso ao registry ao professor — não estão
neste repositório (só o IP é público; a rede da UFT não tem acesso
externo, então não há risco em publicá-lo, mas a senha do registry
continua fora do git).

### Publicando/atualizando a imagem no registry (só o professor)

No servidor `sarue`, uma vez, sobe o registry:
```bash
./sarue/registry_setup.sh
```

Depois de buildar a imagem localmente (veja "Caminho 2" abaixo), publica
a partir da máquina que buildou:
```bash
docker tag quartus13-cli:latest 172.16.13.190:5000/quartus13-cli:latest
docker login 172.16.13.190:5000
docker push 172.16.13.190:5000/quartus13-cli:latest
```

> Usamos um registry auto-hospedado (não Docker Hub) porque o plano
> gratuito do Docker Hub limita repositórios privados a ~2GB, e essa
> imagem tem mais de 6GB — além de evitar redistribuir publicamente os
> binários da Intel/Altera, que são proprietários mesmo na edição
> gratuita.

---

## Caminho 2: Build local a partir do código-fonte

### Pré-requisitos: baixar os instaladores (não incluídos neste repositório)

Os instaladores da Intel/Altera são grandes e proprietários — não podem
ser redistribuídos aqui. Baixe manualmente em:

https://www.altera.com/downloads/fpga-development-tools/quartus-ii-web-edition-design-software-version-13-0sp1-linux

Baixe estes três arquivos e coloque dentro de `local/` (mesmo nível do
`Dockerfile`):

- `QuartusSetupWeb-13.0.1.232.run` (Quartus II Software) — 1.6 GB
- `cyclone_web-13.0.1.232.qdz` (Cyclone II/III/IV Device Support) — 569 MB
- `ModelSimSetup-13.1.0.162.run` (ModelSim-Edition) — ~776 MB

### Setup (uma vez por máquina)

```bash
sudo ./install_docker.sh
sudo ./install_usb_blaster_udev.sh
cd local
docker build -t quartus13-cli:latest .   # builda a imagem (demorado na 1a vez)
```

O build demora bastante na primeira vez — o instalador do Quartus trava
ao final mesmo já tendo terminado (bug conhecido dessa versão), então o
Dockerfile usa um timeout de 30 min por instalador antes de seguir em
frente. Rebuilds seguintes reaproveitam cache e são rápidos.

Pra validar o setup do zero (build + compilação + simulação
automatizadas), use `local/teste_setup.sh` (rodar de dentro de `local/`).

---

## Uso (toda sessão, qualquer um dos dois caminhos)

Com a placa DE1 conectada via USB, a partir da raiz do repositório:

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
quartus_pgm -c "USB-Blaster" -m jtag -o "p;and_gate/and_gate.sof"
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
