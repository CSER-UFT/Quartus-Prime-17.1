#!/bin/bash

if [ $1-UNSET == -UNSET ]
then
	echo "No installation directory defined. Using default /opt/altera/17.1"
	INSTALLDIR="/opt/altera/17.1"
else
	INSTALLDIR=$1
fi

mkdir -p $INSTALLDIR
rm -rf $INSTALLDIR/*

cd Altera

echo "Installing dependencies..."
dnf install -y -b make libX11.x86_64 libX11.i686 libXau.x86_64 libXau.i686 libXdmcp.x86_64 libXdmcp.i686 libXext.x86_64 libXext.i686 libXft-devel.i686 libXft-devel.x86_64 libXft.x86_64 libXft.i686 libXrender.x86_64 libXrender.i686 libXt.x86_64 libXt.i686 libXtst.x86_64 libXtst.i686 gtk2.i686 gtk2.x86_64 unixODBC.i686 unixODBC.x86_64 unixODBC-devel.i686 unixODBC-devel.x86_64 ncurses.x86_64 ncurses-libs.x86_64 ncurses-libs.i686 ncurses-compat-libs.x86_64 ncurses-compat-libs.i686 zeromq.i686 zeromq.x86_64 libXext.x86_64 libXext.i686 alsa-lib.i686 alsa-lib.x86_64 libxml2.i686 libxml2.x86_64 libedit.x86_64 libedit.i686 libXi.x86_64 libXi.i686 gtk-murrine-engine.x86_64 gtk-murrine-engine.i686 libnsl.i686 libnsl.x86_64 libpng12.x86_64 libpng12.i686

echo "This file must exist" > /tmp/bitrock_installer.log
echo "Installing Quartus..."
cd quartus
echo ./QuartusLiteSetup-17.1.0.590-linux.run --unattendedmodeui none --mode unattended --installdir ${INSTALLDIR} --accept_eula 1
./QuartusLiteSetup-17.1.0.590-linux.run --unattendedmodeui none --mode unattended --installdir ${INSTALLDIR} --accept_eula 1 &
PID=$!
tail -F --pid ${PID} /tmp/bitrock_installer_${PID}.log | awk '/Log finished/ {system("kill -9 '$PID'")}' &
tail -F --pid ${PID} /tmp/bitrock_installer_${PID}.log

echo "Installing Modelsim"
cd ../modelsim
echo ./ModelSimSetup-17.1.0.590-linux.run --unattendedmodeui none --mode unattended --installdir ${INSTALLDIR} --accept_eula 1
./ModelSimSetup-17.1.0.590-linux.run --unattendedmodeui none --mode unattended --installdir ${INSTALLDIR} --accept_eula 1 &
PID=$!
tail -F --pid ${PID} /tmp/bitrock_installer_${PID}.log | awk '/Log finished/ {system("kill -9 '$PID'")}' &
tail -F --pid ${PID} /tmp/bitrock_installer_${PID}.log

cd ..
echo "Adding Quartus to PATH"
echo "export PATH=\$PATH:${INSTALLDIR}/quartus/bin" > /etc/profile.d/quartus.sh
chmod +x /etc/profile.d/quartus.sh

echo "Adding Quartus to Applications Menu"
sed 's|<INSTALLDIR>|'${INSTALLDIR}'|g' quartus.desktop > /usr/share/applications/quartus.desktop

echo "Fixing USB permissions"
cp 51-altera-usb-blaster.rules /etc/udev/rules.d/51-altera-usb-blaster.rules
udevadm control --reload

echo "Fix ModelSim kernel compatibility"
sed -i '210s/linux_rh60/linux/g' ${INSTALLDIR}/modelsim_ase/vco

echo "Fix Fonts"
mkdir -p ${INSTALLDIR}/modelsim_ase/fixfonts
cp -r fixfonts/* ${INSTALLDIR}/modelsim_ase/fixfonts/
sed -i '51iexport LD_LIBRARY_PATH='${INSTALLDIR}'/modelsim_ase/fixfonts' ${INSTALLDIR}/modelsim_ase/vco
sed -i '16iexport LD_LIBRARY_PATH='${INSTALLDIR}'/modelsim_ase/fixfonts' ${INSTALLDIR}/quartus/adm/qenv.sh
sed -i '52iexport FONTCONFIG_FILE='${INSTALLDIR}'/modelsim_ase/fixfonts/fonts/fonts.conf' ${INSTALLDIR}/modelsim_ase/vco
sed -i '17iexport FONTCONFIG_FILE='${INSTALLDIR}'/modelsim_ase/fixfonts/fonts/fonts.conf' ${INSTALLDIR}/quartus/adm/qenv.sh


echo "Installation completed"
