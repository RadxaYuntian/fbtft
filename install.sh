#!/bin/bash

set -e

if [[ $EUID != 0 ]]
then
    echo Please run this script as root.
    exit
fi

# install dependency
# sudo apt update && sudo apt install dkms device-tree-compiler git build-essential -y

echo Cloning fbtft source code...
git clone --depth 1 --filter=blob:none --sparse git://git.kernel.org/pub/scm/linux/kernel/git/gregkh/staging.git
cd staging
git sparse-checkout set drivers/staging/fbtft
cd ..

echo Set up fbtft DKMS source
mkdir /usr/src/fbtft-0.1
cp ./Kbuild ./Makefile ./dkms.conf ./LICENSE ./staging/drivers/staging/fbtft/* /usr/src/fbtft-0.1
cp ./staging/drivers/staging/fbtft/Makefile /usr/src/fbtft-0.1/Makefile.staging

echo Install fbtft as DKMS module
dkms build fbtft/0.1
dkms install fbtft/0.1

echo Install bundled SPI display overlays
cd overlays
for f in $(find *.dts -type f); do
        dtc -@ -O dtb -b 0 -o ${f%.*}.dtbo $f
done
cp *.dtbo /boot/dtbs/$(uname -r)/amlogic/overlay/
cd ..

echo "Installation completed. Please enable your display's overlay"
echo "in /boot/uEnv.txt, add the matching driver to /etc/modules, "
echo "and reboot your board for the change to take effect."