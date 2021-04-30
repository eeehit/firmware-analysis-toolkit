#!/bin/sh


set -e
sudo apt update
sudo apt install -y python2 python3-pip python3-pexpect curl unzip busybox-static fakeroot kpartx snmp uml-utilities util-linux vlan qemu-system-arm qemu-system-mips qemu-system-x86 qemu-utils
sudo add-apt-repository universe
sudo apt update
curl https://bootstrap.pypa.io/pip/2.7/get-pip.py --output get-pip.py
sudo python2 get-pip.py
rm get-pip.py

echo "Installing binwalk"
git clone --depth=1 https://github.com/eeehit/binwalk.git
cd binwalk
sudo ./deps.sh --yes

sudo python3 ./setup.py install
sudo -H python3 -m pip install git+https://github.com/ahupp/python-magic
sudo -H python2 -m pip install git+https://github.com/sviehb/jefferson
cd ..

echo "Installing firmadyne"
git clone --recursive https://github.com/eeehit/firmadyne.git
cd firmadyne
./download.sh
firmadyne_dir=$(realpath .)

# Set FIRMWARE_DIR in firmadyne.config
sed -i "/FIRMWARE_DIR=/c\FIRMWARE_DIR=$firmadyne_dir" firmadyne.config

# Comment out psql -d firmware ... in getArch.sh
sed -i 's/psql/#psql/' ./scripts/getArch.sh

# Change interpretor in extractor.py to python3
sed -i 's/env python/env python3/' ./sources/extractor/extractor.py
cd ..

echo "Setting up firmware analysis toolkit"
chmod +x fat.py
chmod +x reset.py

# Set firmadyne_path in fat.config
sed -i "/firmadyne_path=/c\firmadyne_path=$firmadyne_dir" fat.config

cd qemu-builds
wget -O qemu-system-static-2.5.0.zip "https://github.com/attify/firmware-analysis-toolkit/files/4244529/qemu-system-static-2.5.0.zip"
unzip -qq qemu-system-static-2.5.0.zip && rm qemu-system-static-2.5.0.zip
cd ..

echo "====================================================="
echo "Firmware Analysis Toolkit installed successfully!"
echo "Before running fat.py for the first time,"
echo "please edit fat.config and provide your sudo password"
echo "====================================================="
