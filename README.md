# Script de instalação do IntelFPGA Quartus Prime 17.1 no Fedora 31

Esse repositório não contém a distribuição do Software Quartus, que deve ser baixado diretamente do site da Intel. Esse repositório contém apenas um script para instalação facilitada.

Esse script foi desenvolvido para instalar o Quartus Prime versão 17.1 em uma instalação limpa do sistema Fedora 31 Workstation edition. Não há garantias de que ele vá funcionar integralmente em outros cenários, mas ele pode ser usado como base para eles.

## Download do Quartus

1. Se você ainda não tiver uma conta no site da Intel, crie uma [aqui](https://www.intel.com/content/www/us/en/forms/fpga/fpga-individual-registration.html?tgt=http%3A%2F%2Ffpgasoftware.intel.com%2Fsaml_login%2F%3Fsso2)

2. Acesse o link para download do software [aqui](https://fpgasoftware.intel.com/17.1/?edition=lite&platform=linux)

3. Em **Individual Files**, faça o download dos componentes:
  - Quartus Prime (includes Nios II EDS)
  - ModelSim-Intel FPGA Edition (includes Starter Edition)
  - Cyclone V device support

4. Salve os arquivos *QuartusLiteSetup-17.1.0.590-linux.run* e *cyclonev-17.1.0.590.qdz* baixados na pasta *Altera/quartus*.

5. Salve o arquivo *ModelSimSetup-17.1.0.590-linux.run* na pasta *Altera/modelsim*.

## Instalação

Simplesmente execute:

```bash
sudo ./setup_altera.sh
```

## Observação sobre dependências

A linha 17 do script *setup_altera.sh* instala as dependências necessárias para o Quartus. Essas, porém, podem entrar em conflito com a sua instalação do Fedora 31, principalmente devido à instalação de bibliotecas de 32 e 64 bits em conjunto. Nesse caso, a inicialização do Quartus irá falhar.

Caso isso aconteça, recomenda-se que o Quartus seja iniciado em um terminal (linha de comando) para identificação de qual a dependência faltante, e ela seja instalada manualmente no sistema.

## Etapas de instalação implementadas no script

- (Linhas 3-9) Seleção do diretório de instalação;
- (Linha 17) Instalação de dependências;
- (Linhas 19-26) Instalação do Quartus e suporte a Cyclone V - implementada correção para o instalador que "trava" no final da instalação;
- (Linhas 28-34) Instalação do Modelsim - implementada correção para o instalador que "trava" no final da instalação;
- (Linhas 36-39) Adicionar Quartus no PATH do sistema;
- (Linhas 41-42) Adicionar entrada para o Quartus no menu;
- (Linhas 44-46) Permitir comunicação com a placa via USB para usuário não-root;
- (Linhas 48-49) Modelsim falha ao iniciar em Kernel > v3.x;
- (Linhas 51-57) Incompatibilidade do Modelsim com libfreetype atualizada e fontes instaladas no sistema.

