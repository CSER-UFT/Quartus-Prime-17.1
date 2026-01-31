# ==========================================
# Dockerfile: Quartus 17.1 + ModelSim plug-and-play
# Ubuntu 20.04, GUI X11, DE1 via USB
# ==========================================
FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive
ENV INSTALLDIR=/opt/altera/17.1

# -----------------------------
# Instalar dependências
# -----------------------------
RUN dpkg --add-architecture i386 && \
    apt-get update && apt-get install -y \
    build-essential \
    libc6:i386 libncurses5:i386 libstdc++6:i386 zlib1g:i386 \
    libx11-6:i386 libx11-dev libxext6:i386 libxext-dev \
    libxft2:i386 libxft-dev libxrender1:i386 libxrender-dev \
    libxt6:i386 libxt-dev libxtst6:i386 libxtst-dev \
    libxi6:i386 libxi-dev libxau6:i386 libxau-dev libxdmcp6:i386 libxdmcp-dev \
    libgtk2.0-0 libgtk2.0-0:i386 unixodbc unixodbc-dev:i386 \
    libzmq3-dev libncurses5 libncurses5-dev libfreetype6:i386 \
    alsa-base alsa-utils libxml2:i386 libxml2 libedit-dev libedit-dev:i386 \
    libnsl-dev libpng16-16 libpng-dev fonts-dejavu-core \
    x11-apps sudo wget curl && \
    apt-get clean

# -----------------------------
# Criar diretório de instalação
# -----------------------------
RUN mkdir -p $INSTALLDIR

# -----------------------------
# Copiar arquivos de instalação
# -----------------------------
COPY Altera/quartus /tmp/quartus
COPY Altera/modelsim /tmp/modelsim
COPY Altera/51-altera-usb-blaster.rules /tmp/
COPY Altera/fixfonts /tmp/fixfonts

# -----------------------------
# Instalar Quartus
# -----------------------------
WORKDIR /tmp/quartus
RUN chmod +x *.run && \
    ./QuartusLiteSetup-17.1.0.590-linux.run --unattendedmodeui none --mode unattended --installdir $INSTALLDIR --accept_eula 1

# -----------------------------
# Instalar ModelSim
# -----------------------------
WORKDIR /tmp/modelsim
RUN chmod +x *.run && \
    ./ModelSimSetup-17.1.0.590-linux.run --unattendedmodeui none --mode unattended --installdir $INSTALLDIR --accept_eula 1

# -----------------------------
# Configurar PATH e suporte
# -----------------------------
RUN echo "export PATH=\$PATH:$INSTALLDIR/quartus/bin" > /etc/profile.d/quartus.sh && \
    chmod +x /etc/profile.d/quartus.sh && \
    cp /tmp/51-altera-usb-blaster.rules /etc/udev/rules.d/ && \
    udevadm control --reload && udevadm trigger && \
    mkdir -p $INSTALLDIR/modelsim_ase/fixfonts && \
    cp -r /tmp/fixfonts/* $INSTALLDIR/modelsim_ase/fixfonts/ && \
    sed -i '51iexport LD_LIBRARY_PATH='"$INSTALLDIR"'/modelsim_ase/fixfonts' "$INSTALLDIR/modelsim_ase/vco" && \
    sed -i '16iexport LD_LIBRARY_PATH='"$INSTALLDIR"'/modelsim_ase/fixfonts' "$INSTALLDIR/quartus/adm/qenv.sh" && \
    sed -i '52iexport FONTCONFIG_FILE='"$INSTALLDIR"'/modelsim_ase/fixfonts/fonts/fonts.conf' "$INSTALLDIR/modelsim_ase/vco" && \
    sed -i '17iexport FONTCONFIG_FILE='"$INSTALLDIR"'/modelsim_ase/fixfonts/fonts/fonts.conf' "$INSTALLDIR/quartus/adm/qenv.sh" && \
    sed -i '210s/linux_rh60/linux/g' "$INSTALLDIR/modelsim_ase/vco"

# -----------------------------
# Usuário não-root
# -----------------------------
RUN useradd -ms /bin/bash student && \
    echo "student ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
USER student
WORKDIR /home/student

# -----------------------------
# Comando plug-and-play: inicia GUI do Quartus
# -----------------------------
CMD ["/bin/bash", "-c", "source /etc/profile.d/quartus.sh && quartus & sleep 5 && tail -f /dev/null"]
