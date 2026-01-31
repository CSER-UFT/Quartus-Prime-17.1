# Script de instalação do Intel FPGA Quartus Prime 17.1 no Ubuntu 16.04 LTS

Este repositório **não contém o software Quartus**, que deve ser baixado diretamente do site da Intel. Ele fornece apenas um **script de instalação facilitada** para sistemas Ubuntu 16.04 LTS.

O script instala o **Quartus Prime versão 17.1** e o **ModelSim Intel FPGA Edition** em uma instalação limpa do Ubuntu 16.04. Ele pode servir de base para outras versões do Ubuntu ou cenários diferentes, mas **não há garantias de funcionamento completo** fora do Ubuntu 16.04.

---

## Download do Quartus

Use o link oficial da Intel:  
[Quartus Prime 17.1 Linux](https://www.intel.com/content/www/us/en/software-kit/669392/intel-quartus-prime-standard-edition-design-software-version-17-1-for-linux.html)

**Passos para download:**

1. Se ainda não tiver uma conta Intel, crie uma no site da Intel.
2. Acesse o link acima e selecione **Linux** como plataforma.
3. Escolha a aba de **Individual Files** ou arquivos individuais.
4. Faça o download dos arquivos:
   - QuartusPrime 17.1 (**QuartusLiteSetup-17.1.0.590-linux.run**)  
   - Suporte para dispositivos (ex.: **cyclonev-17.1.0.590.qdz**)  
   - ModelSim Intel FPGA Edition (**ModelSimSetup-17.1.0.590-linux.run**)  
5. Salve o instalador do Quartus na pasta `Altera/quartus`.  
6. Salve o instalador do ModelSim na pasta `Altera/modelsim`.

> **Observação:** a pasta `Altera/` também contém arquivos de suporte essenciais:
> - `51-altera-usb-blaster.rules` ? regras de permissão para placas DE1.  
> - `fixfonts/` ? fontes para corrigir problemas no ModelSim.  
> - `quartus.desktop` ? atalho no menu de aplicativos.  

---

## Instalação

Execute o script como administrador:

```bash
sudo ./setup_altera.sh
```

O script fará automaticamente:

- Instalação de dependências (32 e 64 bits) essenciais para Quartus e ModelSim  
- Instalação do Quartus Prime 17.1  
- Instalação do ModelSim Intel FPGA Edition  
- Configuração do **PATH** (`/etc/profile.d/quartus.sh`)  
- Criação de **atalho no menu de aplicativos**  
- Configuração de **permissões USB** para placas FPGA  
- Aplicação de **correções de fontes** para ModelSim  

---

## Observações sobre dependências

O script instala dependências essenciais para Ubuntu 16.04.  

Em alguns casos, pode haver **conflitos ou bibliotecas ausentes**, causando falha na inicialização. Se isso ocorrer:

1. Inicie o Quartus ou ModelSim via terminal:

```bash
quartus &
# ou
vsim &
```

2. O terminal exibirá mensagens de bibliotecas faltantes.
3. Instale manualmente os pacotes ausentes usando:

```bash
sudo apt-get install <pacote>
```

## Etapas de instalação implementadas no script

| Etapa | Linha(s) | Descrição |
|-------|----------|-----------|
| Seleção do diretório de instalação | 3-9 | Define diretório padrão `/opt/altera/17.1` ou permite diretório customizado |
| Instalação de dependências | 17-26 | Instala pacotes necessários (32-bit e 64-bit) no Ubuntu 16.04 |
| Instalação do Quartus e suporte Cyclone V | 28-34 | Executa instalador do Quartus, aplicando correções finais |
| Instalação do ModelSim | 36-42 | Executa instalador do ModelSim, aplicando correções finais |
| Configuração do PATH do Quartus | 44-47 | Cria script em `/etc/profile.d/quartus.sh` |
| Criação do menu de aplicativos | 49-50 | Cria atalho em `/usr/share/applications/quartus.desktop` |
| Configuração de permissões USB | 52-54 | Permite uso do USB-Blaster por usuários não-root |
| Correção de compatibilidade do ModelSim | 56-57 | Ajuste de kernel e bibliotecas para execução correta |
| Correção de fontes do ModelSim | 59-66 | Instala fontes e ajusta `LD_LIBRARY_PATH` e `FONTCONFIG_FILE` |

---

## Resultado esperado

Após a execução do script:

- Quartus Prime 17.1 e ModelSim estão instalados e configurados no Ubuntu 16.04.  
- Placas FPGA (DE1/DE1-SoC) podem ser programadas sem sudo.  
- Menu de aplicativos contém atalho para Quartus.  
- Problemas de fontes no ModelSim são corrigidos automaticamente.  

> **Recomendação:** reinicie o shell ou execute:

```bash
source /etc/profile.d/quartus.sh
```
