# Script de instalação do Intel FPGA Quartus Prime 17.1 no Ubuntu 20.04 LTS

Este repositório **não contém o software Quartus**, que deve ser baixado diretamente do site da Intel. Ele fornece apenas um **script de instalação facilitada** para sistemas Ubuntu 20.04 LTS.

O script instala o **Quartus Prime versão 17.1** e o **ModelSim Intel FPGA Edition** em uma instalação limpa do Ubuntu 20.04. Ele pode servir de base para outras versões do Ubuntu ou cenários diferentes, mas **não há garantias de funcionamento completo** em outros ambientes.

---

## Download do Quartus

Use o link oficial da Intel:  
[Quartus Prime 17.1 Linux](https://www.intel.com/content/www/us/en/software-kit/669392/intel-quartus-prime-standard-edition-design-software-version-17-1-for-linux.html)

Passos para download:

1. Se ainda não tiver conta Intel, crie uma no site da Intel.
2. Acesse o link acima e selecione Linux como plataforma.
3. Escolha a aba de ?Individual Files? ou arquivos individuais.
4. Faça o download dos arquivos:
   - QuartusPrime 17.1 (**QuartusLiteSetup-17.1.0.590-linux.run**)  
   - Suporte para dispositivos (ex.: **cyclonev-17.1.0.590.qdz**)  
5. Salve o instalador do Quartus na pasta `Altera/quartus`.  
6. Salve o instalador do ModelSim na pasta `Altera/modelsim`.

---

## Instalação

Execute o script como administrador:

```bash
sudo ./setup_altera.sh
```

O script instalará automaticamente dependências, Quartus Prime, ModelSim, configurará o PATH, menu de aplicativos e permissões USB para placas FPGA.

---

## Observação sobre dependências

O script instala **dependências de 64 e 32 bits**, essenciais para o Quartus 17.1 e ModelSim.  

Em alguns casos, pode haver **conflitos de bibliotecas**, causando falha na inicialização. Se isso ocorrer:

1. Inicie o Quartus ou ModelSim via terminal:

```bash
quartus &
# ou
vsim &
```

2. O terminal exibirá mensagens de bibliotecas faltantes.
3. Instale manualmente os pacotes ausentes usando `sudo apt-get install <pacote>`.

---

## Etapas de instalação implementadas no script

| Etapa | Linha(s) | Descrição |
|-------|----------|-----------|
| Seleção do diretório de instalação | 3-9 | Define diretório padrão `/opt/altera/17.1` ou permite diretório customizado |
| Instalação de dependências | 17-26 | Instala pacotes necessários (32-bit e 64-bit) no Ubuntu 20.04 |
| Instalação do Quartus e suporte Cyclone V | 28-34 | Executa instalador, com correções para travamentos finais |
| Instalação do ModelSim | 36-42 | Executa instalador, com correções para travamentos finais |
| Adição do Quartus ao PATH | 44-47 | Cria script em `/etc/profile.d/quartus.sh` |
| Adição do Quartus ao menu de aplicativos | 49-50 | Cria atalho em `/usr/share/applications/quartus.desktop` |
| Configuração de permissões USB | 52-54 | Permite uso do USB Blaster por usuários não-root |
| Correção de compatibilidade do ModelSim | 56-57 | Ajuste de kernel e bibliotecas para execução correta |
| Correção de fontes do ModelSim | 59-66 | Instala fontes e ajusta `LD_LIBRARY_PATH` e `FONTCONFIG_FILE` |

