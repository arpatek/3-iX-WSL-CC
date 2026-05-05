#!/bin/bash
# Title         :CM6-Flash.sh
# Description   :Script to Flash CM6 Drives
# Author        :Juan Garcia
# Date          :11-11-22
# Version       :1.0

# Create directory for data
cd /var/tmp || exit
mkdir -p cm6-tmp

# Output separator to LINE-Output.txt
echo "==========================================================================" >> cm6-tmp/LINE-Output.txt

# Get serial number
dmidecode -t1 | grep -E -o -i "A1-.{0,6}" > cm6-tmp/System-Serial.txt
SERIAL=$(cat cm6-tmp/System-Serial.txt)

# Output separator to LINE-Output.txt
echo "==========================================================================" >> cm6-tmp/LINE-Output.txt

# CM6 NVME Check
{
    echo -e "+----------------+";
    echo "+[CM6 NVME FLASH]+";
    echo -e "+----------------+\n\n";
    nvmecontrol devlist | grep -F -e "CM6";
    nvmecontrol devlist | grep -F -e "CM6" | sed 's/^ *//g';
    echo -e "\n";
    cat cm6-tmp/NVMEcontrol-Check.txt | cut -d ":" -f1 | sed 's/^ *//g' | xargs -0 | sed '$d'
} >> cm6-tmp/NVD-List.txt

# Loop through NVME devices and perform admin-passthru
FILE=cm6-tmp/NVD-List.txt
NVME=""
exec 3<&0
exec 0<$FILE
while read -r line
do
  NVME=$(echo "$line" | cut -d " " -f1)

  echo "nvmecontrol admin-passthru -o 0xC4 -n=0 -4 0x0100 -5 0x0 -6 0x0 $NVME" >> cm6-tmp/"$SERIAL"-CM6-CHECK.txt
  nvmecontrol admin-passthru -o 0xC4 -n=0 -4 0x0100 -5 0x0 -6 0x0 "$NVME" >> cm6-tmp/"$SERIAL"-CM6-CHECK.txt

done

# Output separator to LINE-Output.txt
echo "==========================================================================" >> cm6-tmp/LINE-Output.txt

# Compress output file
tar cfz "$SERIAL-CM6-Flash.tar.gz" cm6-tmp/

# Output separator to LINE-Output.txt
echo "==========================================================================" >> cm6-tmp/LINE-Output.txt

# Configure SMB connection (replace placeholders)
echo "[SMB_HOST:ROOT]" > ~/.nsmbrc
echo "password=YOUR_PASSWORD" >> ~/.nsmbrc
cat ~/.nsmbrc

# Mount SJ Storage
mkdir /mnt/sj-storage
mount_smbfs -N -I YOUR_SMB_IP //root@YOUR_SMB_HOST/sj-storage/ /mnt/sj-storage || mount -t cifs -o vers=3,username=root,password=YOUR_PASSWORD '//YOUR_SMB_HOST/sj-storage/' /mnt/sj-storage/
echo "SJ Storage Mounted"

# Output separator to LINE-Output.txt
echo "==========================================================================" >> cm6-tmp/LINE-Output.txt

# Copy tar.gz file to swqc-output
cd /var/tmp || return
cp -- *glob*.tar.gz /mnt/sj-storage/swqc-output
echo "Finished Copying tar.gz File To swqc-output On sj-storage"

# Output separator to LINE-Output.txt
echo "==========================================================================" >> cm6-tmp/LINE-Output.txt

# Clean up
rm -rf -- *glob*.tar.gz cm6-tmp/

exit
