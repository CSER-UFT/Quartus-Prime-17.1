#!/bin/bash

# ==========================================
# Intel FPGA Quartus Prime 17.1 Installer
# Adaptado para Ubuntu 16.04 LTS
# ==========================================

set -e

# -----------------------------
# Definir diretório de instalação
# -----------------------------
if [ "$1-UNSET" == "-UNSET" ]; then
    echo "No installation directory defined. Using default /opt/altera/17.1"
    INSTALLDIR="/opt/altera/17.1"
else
    INSTALLDIR=$1
fi

sudo mkdir -p "$INSTALLDIR"
sudo rm -rf "$INSTALLDIR"/*

cd Altera || { echo "Altera directory not found!"; exit 1; }

# -----------------------------
# Instala dependências Ubuntu 16.04
# -----------------------------
echo "Installing dependencies..."
sudo dpkg --add-architecture i386
sudo apt-get update
sudo apt-get install -y build-essential \
    libc6:i386 libncurses5:i386 libstdc++6:i386 zlib1g:i386 \
    libx11-6:i386 libx11-dev libxext6:i386 libxext-dev \
    libxft2:i386 libxft-dev libxrender1:i386 libxrender-dev \
    libxt6:i386 libxt-dev libxtst6:i386 libxtst-dev \
    libxi6:i386 libxi-dev libxau6:i386 libxau-dev libxdmcp6:i386 libxdmcp-dev \
    libgtk2.0-0 libgtk2.0-0:i386 unixodbc unixodbc-dev:i386 \
    libzmq3-dev libncurses5 libncurses5-dev libfreetype6:i386 \
    alsa-base alsa-utils libxml2:i386 libxml2 libedit-dev libedit-dev:i386 \
    libnsl-dev libpng12-0 libpng12-dev fonts-dejavu-core \
    sudo curl wget

# -----------------------------
# Instalação Quartus
# -----------------------------
echo "Installing Quartus..."
cd quartus
chmod +x *.run
./QuartusLiteSetup-17.1.0.590-linux.run --unattendedmodeui none --mode unattended --installdir "$INSTALLDIR" --accept_eula 1 &
PID=$!
wait $PID
cd ..

# -----------------------------
# Instalação ModelSim
# -----------------------------
echo "Installing ModelSim..."
cd modelsim
chmod +x *.run
./ModelSimSetup-17.1.0.590-linux.run --unattendedmodeui none --mode unattended --installdir "$INSTALLDIR" --accept_eula 1 &
PID=$!
wait $PID
cd ..

# -----------------------------
# Configurar PATH do Quartus
# -----------------------------
echo "Adding Quartus to PATH..."
echo "export PATH=\$PATH:$INSTALLDIR/quartus/bin" | sudo tee /etc/profile.d/quartus.sh
sudo chmod +x /etc/profile.d/quartus.sh

# -----------------------------
# Aplicar arquivos de suporte da pasta Altera
# -----------------------------
echo "Applying support files from Altera folder..."

# USB Blaster rules
sudo cp 51-altera-usb-blaster.rules /etc/udev/rules.d/
sudo udevadm control --reload
sudo udevadm trigger

# Fix fonts para ModelSim
mkdir -p "$INSTALLDIR/modelsim_ase/fixfonts"
cp -r fixfonts/* "$INSTALLDIR/modelsim_ase/fixfonts/"

sed -i '51iexport LD_LIBRARY_PATH='"$INSTALLDIR"'/modelsim_ase/fixfonts' "$INSTALLDIR/modelsim_ase/vco"
sed -i '16iexport LD_LIBRARY_PATH='"$INSTALLDIR"'/modelsim_ase/fixfonts' "$INSTALLDIR/quartus/adm/qenv.sh"
sed -i '52iexport FONTCONFIG_FILE='"$INSTALLDIR"'/modelsim_ase/fixfonts/fonts/fonts.conf' "$INSTALLDIR/modelsim_ase/vco"
sed -i '17iexport FONTCONFIG_FILE='"$INSTALLDIR"'/modelsim_ase/fixfonts/fonts/fonts.conf' "$INSTALLDIR/quartus/adm/qenv.sh"

# Menu de aplicativos
sudo sed 's|<INSTALLDIR>|'"$INSTALLDIR"'|g' quartus.desktop | sudo tee /usr/share/applications/quartus.desktop

# -----------------------------
# ModelSim kernel compatibility
# -----------------------------
echo "Fixing ModelSim kernel compatibility..."
sudo sed -i '210s/linux_rh60/linux/g' "$INSTALLDIR/modelsim_ase/vco"

echo "======================================="
echo "Intel FPGA Quartus Prime 17.1 Installed on Ubuntu 16.04 LTS!"
echo "Installation directory: $INSTALLDIR"
echo "Please restart your shell or run 'source /etc/profile.d/quartus.sh'"
echo "======================================="
