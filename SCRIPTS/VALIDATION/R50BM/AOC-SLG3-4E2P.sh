#!/bin/bash
# Title: AOC-SLG3-4E2P.sh
# Description: Script to Flash AOC-SLG3-4E2P on TrueNAS-R50BM
# Author: Juan Garcia
# Updated: 11-11-22
# Version: 1.0

# Create directory for data
cd /var/tmp || exit
mkdir -p ix-tmp

# Output separator to LINE-Output.txt
echo "==========================================================================" >> ix-tmp/LINE-Output.txt

# Get serial number
dmidecode -t1 | grep -E -o -i "A1-.{0,6}" > ix-tmp/System-Serial.txt
SERIAL=$(cat ix-tmp/System-Serial.txt)

# Make plx_eeprom executable
chmod +x ./plx_eeprom

# Find PCI-E devices
pciconf -lvb | grep -A5 "PEX" | head -5 | grep "base" | cut -d "," -f3 | xargs | cut -d " " -f2- > ix-tmp/PCI-E-Devices.txt
PCIE=$(cat ix-tmp/PCI-E-Devices.txt)

# Check EEPROM status pre-flash
printf "EEPROM STATUS PRE-FLASH:\n\n" >> ix-tmp/"$SERIAL"-R50BM-FLASH.txt
./plx_eeprom -b "$PCIE" > ix-tmp/EEPROM-Status.txt
./plx_eeprom -b "$PCIE" >> ix-tmp/"$SERIAL"-R50BM-FLASH.txt

# Flash the card using EEPROM image
printf "\n\n-----\n" >> ix-tmp/"$SERIAL"-R50BM-FLASH.txt
./plx_eeprom -b "$PCIE" -w -f /var/tmp/sm_patch2.eep > ix-tmp/EEPROM-Flash-Check.txt
./plx_eeprom -b "$PCIE" -w -f /var/tmp/sm_patch2.eep >> ix-tmp/"$SERIAL"-R50BM-FLASH.txt
printf "-----\n\n" >> ix-tmp/"$SERIAL"-R50BM-FLASH.txt

# Check EEPROM status post-flash
printf "EEPROM STATUS POST-FLASH:\n\n" >> ix-tmp/"$SERIAL"-R50BM-FLASH.txt
./plx_eeprom -b "$PCIE" > ix-tmp/EEPROM-Status-Flashed.txt
./plx_eeprom -b "$PCIE" >> ix-tmp/"$SERIAL"-R50BM-FLASH.txt

# Output separator to LINE-Output.txt
echo "==========================================================================" >> ix-tmp/LINE-Output.txt

# Compress output file
tar cfz "$SERIAL-AOC-SLG3-4E2P.tar.gz" ix-tmp/

# Output separator to LINE-Output.txt
echo "==========================================================================" >> ix-tmp/LINE-Output.txt

# Configure SMB connection (replace placeholders)
echo "[SMB_HOST:ROOT]" > ~/.nsmbrc
echo "password=YOUR_PASSWORD" >> ~/.nsmbrc
cat ~/.nsmbrc

# Mount SJ Storage
mkdir /mnt/sj-storage
mount_smbfs -N -I YOUR_SMB_IP //root@YOUR_SMB_HOST/sj-storage/ /mnt/sj-storage || mount -t cifs -o vers=3,username=root,password=YOUR_PASSWORD '//YOUR_SMB_HOST/sj-storage/' /mnt/sj-storage/
echo "SJ Storage Mounted"

# Output separator to LINE-Output.txt
echo "==========================================================================" >> ix-tmp/LINE-Output.txt

# Copy tar.gz file to swqc-output
cd /var/tmp || return
cp -- *glob*.tar.gz /mnt/sj-storage/swqc-output
echo "Finished Copying tar.gz File To swqc-output On sj-storage"

# Output separator to LINE-Output.txt
echo "==========================================================================" >> ix-tmp/LINE-Output.txt

# Clean up
rm -rf -- *glob*.tar.gz ix-tmp/

exit
