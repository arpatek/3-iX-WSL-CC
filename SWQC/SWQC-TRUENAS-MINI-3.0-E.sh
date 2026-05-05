#!/bin/bash
#########################################################################################################
# Title: SWQC-MINI-E.sh
# Description: SWQC For TrueNAS Systems After Client Configuration
# Author: jgarcia@ixsystems.com
# Updated: 03:30:2023
# Version: 1.0
#########################################################################################################

# Moving To /tmp Directory And Creating Our Temporary Folder Where Our Files Will Go

cd /tmp || exit
mkdir swqc-tmp

# Grabbing System Serial Number

SERIAL=$(dmidecode -t1 | grep -Eoi "A1-.{0,6}" | head -n 1)
echo "$SERIAL" >swqc-tmp/"$SERIAL"-System-Serial.txt

# Getting Product Name

dmidecode -t1 | grep -i "Product Name" | cut -d ":" -f 2 | xargs >swqc-tmp/"$SERIAL"-Product-Name.txt
PRODUCT=$(cat swqc-tmp/"$SERIAL"-Product-Name.txt)

# Getting Product Version

dmidecode -t1 | grep -i "Version" | cut -d ":" -f 2 | xargs >swqc-tmp/"$SERIAL"-Product-Version.txt
PVERSION=$(cat swqc-tmp/"$SERIAL"-Product-Version.txt)

#########################################################################################################

# Getting TrueNAS Version

cut </etc/version -d " " -f 1 >swqc-tmp/"$SERIAL"-TrueNAS-Version.txt
TVERSION=$(cat swqc-tmp/"$SERIAL"-TrueNAS-Version.txt)

# Grabbing Motherboard Info (Redbook Pg. 13)

dmidecode -t2 | grep -i 'Product' | awk '{$1=$1};1' | cut -d " " -f 3 >swqc-tmp/"$SERIAL"-Motherboard-Info.txt
MOTHERBOARD=$(cat swqc-tmp/"$SERIAL"-Motherboard-Info.txt)

dmidecode -t2 | grep -i "Version" | cut -d ":" -f 2 | xargs >swqc-tmp/"$SERIAL"-Motherboard-Version.txt
MBVERSION=$(cat swqc-tmp/"$SERIAL"-Motherboard-Version.txt)

# Grabbing BIOS Version (Redbook Pg. 6)

dmidecode -t bios info | grep -i "Version" | cut -d ":" -f 2 | xargs >swqc-tmp/"$SERIAL"-BIOS-Version.txt
BIOVER=$(cat swqc-tmp/"$SERIAL"-BIOS-Version.txt)

# TrueNAS Mini E BIOS Firmware Check

if [[ $BIOVER == *"1.11C"* ]]; then
    echo "  - BIOS Version For $PRODUCT Is Correctly Showing As $BIOVER" >>swqc-tmp/"$SERIAL"-BIOS-Version-Check.txt
else
    echo "  - BIOS Version For $PRODUCT Is Showing As $BIOVER It Should Be 1.11C" >>swqc-tmp/"$SERIAL"-BIOS-Version-Check.txt
fi
BIOSCHECK=$(cat swqc-tmp/"$SERIAL"-BIOS-Version-Check.txt)

# Grabbing BMC Firmware Version (Redbook Pg. 6)

ipmitool bmc info | grep -i "Firmware Revision" | cut -d ":" -f 2 | xargs >swqc-tmp/"$SERIAL"-BMC-Version.txt
BMCINFO=$(cat swqc-tmp/"$SERIAL"-BMC-Version.txt)

# TrueNAS Mini E BMC Firmware Check

if [[ $BMCINFO == *"1.00"* ]]; then
    echo "  - BMC Version For $PRODUCT Is Correctly Showing As $BMCINFO" >>swqc-tmp/"$SERIAL"-BMC-Version-Check.txt
else
    echo "  - BMC Version For $PRODUCT Is Showing As $BMCINFO It Should Be 1.00" >>swqc-tmp/"$SERIAL"-BMC-Version-Check.txt
fi
BMCCHECK=$(cat swqc-tmp/"$SERIAL"-BMC-Version-Check.txt)

# Grabbing Enclosure Info

sesutil map | more | grep -Ei "Enclosure Name" | cut -d ":" -f 2 | awk '{$1=$1};1' >swqc-tmp/"$SERIAL"-Enclosure-Info.txt
ENCLOSUREINFO=$(cat swqc-tmp/"$SERIAL"-Enclosure-Info.txt)

#########################################################################################################

# Getting CPU Info

dmidecode -t processor | grep -Ei 'CPU|Core|Version|Serial|Speed|Manufacturer' | awk '{$1=$1};1' >swqc-tmp/"$SERIAL"-CPU-Info.txt
CPU=$(cat swqc-tmp/"$SERIAL"-CPU-Info.txt)

dmidecode -t processor | grep -c 'Socket Designation: CPU' >swqc-tmp/"$SERIAL"-CPU-Count.txt
CPUCOUNT=$(cat swqc-tmp/"$SERIAL"-CPU-Count.txt)

#########################################################################################################

# Getting Mermory Info

dmidecode -t memory | grep -Ei 'Manufacturer|Serial|Size|Speed|Locator' | awk '{$1=$1};1' >swqc-tmp/"$SERIAL"-Memory-Info.txt
MEMINFO=$(cat swqc-tmp/"$SERIAL"-Memory-Info.txt)

dmidecode -t memory | grep -Ei Size | grep -Ev 'No|Non|Volatile' | awk '{$1=$1};1' >swqc-tmp/"$SERIAL"-Memory-Capacity.txt
MEMCAP=$(cat swqc-tmp/"$SERIAL"-Memory-Capacity.txt)

dmidecode -t memory | grep -Ei Size | grep -Ev 'No|Non|Volatile' | awk '{$1=$1};1' | wc -l | xargs >swqc-tmp/"$SERIAL"-Memory-Count.txt
MEMCOUNT=$(cat swqc-tmp/"$SERIAL"-Memory-Count.txt)

# Getting Total Physical Memory

sysctl -n hw.physmem | awk '{ byte =$1 /1024/1024/1024; print byte " GB" }' >swqc-tmp/"$SERIAL"-TPM.txt
TPM=$(cat swqc-tmp/"$SERIAL"-TPM.txt)

#########################################################################################################

# Getting NIC Info

dmesg | grep -Ei "Ethernet|Network" >swqc-tmp/"$SERIAL"-NIC-Info.txt
NICS=$(cat swqc-tmp/"$SERIAL"-NIC-Info.txt)

# Getting Port Names

ifconfig -a | sed 's/[ \t].*//;/^$/d' >swqc-tmp/"$SERIAL"-Ports.txt
PORTS=$(cat swqc-tmp/"$SERIAL"-Ports.txt)

# Getting Port Info

ifconfig -a >swqc-tmp/"$SERIAL"-Port-Info.txt
PORTINFO=$(cat swqc-tmp/"$SERIAL"-Port-Info.txt)

# Getting Port Count

ifconfig -a | sed 's/[ \t].*//;/^$/d' | grep -Ec "lo0|pflog0" >swqc-tmp/"$SERIAL"-Port-Count.txt
PORTCOUNT=$(cat swqc-tmp/"$SERIAL"-Port-Count.txt)

# Checking for Add-On NIC (Redbook Pg. 21)

if pciconf -lvcb | grep -q "T520"; then
    pciconf -lvcb | grep -i T520 >swqc-tmp/"$SERIAL"-10G-Card.txt
else
    echo "No T520 Add-On NIC Installed" >swqc-tmp/"$SERIAL"-10G-Card.txt
fi
ADDONCARD=$(cat swqc-tmp/"$SERIAL"-10G-Card.txt)

#########################################################################################################

# Getting System Hostname

hostname >swqc-tmp/"$SERIAL"-Hostname.txt
SYSHOSTNAME=$(cat swqc-tmp/"$SERIAL"-Hostname.txt)

# Getting System Default Route

netstat -rn | grep -i "default" >swqc-tmp/"$SERIAL"-Default-Route.txt
DEFAULTRT=$(cat swqc-tmp/"$SERIAL"-Default-Route.txt)

# Getting System DNS Servers

cat /etc/resolv.conf >swqc-tmp/"$SERIAL"-DNS-Servers.txt
DNSSERVERS=$(cat swqc-tmp/"$SERIAL"-DNS-Servers.txt)

# Getting System IPMI Info

ipmitool lan print >swqc-tmp/"$SERIAL"-IPMI-Info.txt
IPMI=$(cat swqc-tmp/"$SERIAL"-IPMI-Info.txt)

#########################################################################################################

# Grabbing Drive Info

camcontrol devlist >swqc-tmp/"$SERIAL"-Drive-Info.txt
CAM=$(cat swqc-tmp/"$SERIAL"-Drive-Info.txt)

# Grabbing Drive Count

camcontrol devlist | grep -iv "AHCI" | grep -iv "iX" | grep -iv "virtual" | grep -Eoi "pass.{0,6}" | cut -d ")" -f 1 | wc -l | xargs >swqc-tmp/"$SERIAL"-Drive-Count.txt
DRIVECOUNT=$(cat swqc-tmp/"$SERIAL"-Drive-Count.txt)

# Grabbing Drive Names

camcontrol devlist | grep -iv "AHCI" | grep -iv "iX" | grep -iv "virtual" | grep -Eoi "pass.{0,6}" | cut -d ")" -f 1 >swqc-tmp/"$SERIAL"-Drive-Names.txt
DEVNAMES=$(cat swqc-tmp/"$SERIAL"-Drive-Names.txt)

# Grabbing NVME Info

smartctl -x /dev/nvme* | grep -i /dev | cut -d/ -f3 | grep -iv "ns1" >swqc-tmp/"$SERIAL"-NVME-Info.txt
NVMEDRIVES=$(cat swqc-tmp/"$SERIAL"-NVME-Info.txt)

# Grabbing NVME Count

smartctl -x /dev/nvme* | grep -i /dev | cut -d/ -f 3 | grep -cv "ns1" >swqc-tmp/"$SERIAL"-NVME-Info.txt
NVMEDRIVECOUNT=$(cat swqc-tmp/"$SERIAL"-NVME-Info.txt)

# Grabbing SMART Info

camcontrol devlist | cut -d, -f 2 | tr -d \) | grep -v "ses" | xargs -I DRIVE smartctl -x /dev/DRIVE >swqc-tmp/"$SERIAL"-SMART-Info.txt
SMARTOUT=$(cat swqc-tmp/"$SERIAL"-SMART-Info.txt)

# Grabbing Drive Capacity

camcontrol devlist | cut -d, -f 2 | tr -d \) | grep -v "ses" | xargs -I DRIVE smartctl -x /dev/DRIVE | grep -Ei "Device Model|Serial Number|User Capacity|Product" | grep -Ev TrueNAS >swqc-tmp/"$SERIAL"-Drive-Capacity.txt
DRIVECAP=$(cat swqc-tmp/"$SERIAL"-Drive-Capacity.txt)

camcontrol devlist | cut -d, -f2 | tr -d \) | grep -v "ses" | xargs -I DRIVE smartctl -A /dev/DRIVE | grep -i "Current Drive Temperature" >swqc-tmp/"$SERIAL"-Drive-Temp.txt
DRIVETEMP=$(cat swqc-tmp/"$SERIAL"-Drive-Temp.txt)

# Getting Boot Device Info (Redbook Pg. 15)

camcontrol devlist | grep "16GB SATA" | awk '{$1=$1};1' >swqc-tmp/"$SERIAL"-Boot-Device.txt
BOOTDRIVE=$(cat swqc-tmp/"$SERIAL"-Boot-Device.txt)

#########################################################################################################

# Get Sensor Output Information

ipmitool sdr list >swqc-tmp/"$SERIAL"-SDR-List.txt
SDROUT=$(cat swqc-tmp/"$SERIAL"-SDR-List.txt)

ipmitool sdr list | grep -i 'Status' >swqc-tmp/"$SERIAL"-SDR-PS.txt
PSSDROUT=$(cat swqc-tmp/"$SERIAL"-SDR-PS.txt)

ipmitool sdr type 'Power Supply' >swqc-tmp/"$SERIAL"-SDR-Type-PS.txt
SDRTYPEPOWER=$(cat swqc-tmp/"$SERIAL"-SDR-Type-PS.txt)

ipmitool sel list | grep -i "power" >swqc-tmp/"$SERIAL"-SEL-Power.txt
POWERSEL=$(cat swqc-tmp/"$SERIAL"-SEL-Power.txt)

dmidecode -t chassis | grep -i "Power Supply State:" | cut -d " " -f 4 >swqc-tmp/"$SERIAL"-PWR-State.txt
PWRSTATE=$(cat swqc-tmp/"$SERIAL"-PWR-State.txt)

ipmitool sel list >swqc-tmp/"$SERIAL"-SEL-List.txt
SELINFO=$(cat swqc-tmp/"$SERIAL"-SEL-List.txt)

ipmitool sensor list >swqc-tmp/"$SERIAL"-Sensor-List.txt
SENSOROUT=$(cat swqc-tmp/"$SERIAL"-Sensor-List.txt)

#########################################################################################################

# Getting Read/Write Cache Drive Info (Redbook Pg. 21 & 49)

camcontrol devlist | grep -i "Micron 5300 MTFDDAK480TDS" | cut -d, -f 2 | tr -d \) | grep -v "ses" | xargs -I DRIVE smartctl -x /dev/DRIVE | grep -Ei "Device Model|Serial Number|User Capacity" >>swqc-tmp/"$SERIAL"-RW-Cache.txt
RWCACHECAP=$(cat swqc-tmp/"$SERIAL"-RW-Cache.txt)

if [ -s swqc-tmp/"$SERIAL"-RW-Cache.txt ]; then
    echo "Read/Write Cache Device Found: Check If Overprovisioning Is Required" >swqc-tmp/"$SERIAL"-RW-Cache-Check.txt
else
    echo "No Read/Write Cache Device Found" >swqc-tmp/"$SERIAL"-RW-Cache-Check.txt
fi
RWCACHECHECK=$(cat swqc-tmp/"$SERIAL"-RW-Cache-Check.txt)

#########################################################################################################

# Collecting Debug And Moving It Into swqc-tmp/

freenas-debug -A

mv fndebug swqc-tmp/
mv smart.out swqc-tmp/"$SERIAL"-SMART-Check.txt

# Checking For TrueNAS License

cat /data/license >swqc-tmp/"$SERIAL"-License.txt
LICENSE=$(cat swqc-tmp/"$SERIAL"-License.txt)

# Check If License-Check File Is Empty

if [ -s swqc-tmp/"$SERIAL"-License.txt ]; then
    echo "PRESENT" >>swqc-tmp/"$SERIAL"-License-Check.txt

    # Getting License Key Info

    grep <swqc-tmp/fndebug/System/dump.txt "License(" | cut -d "'" -f 2 >swqc-tmp/"$SERIAL"-Model-Type.txt
    grep <swqc-tmp/fndebug/System/dump.txt "License(" | cut -d "'" -f 4 >swqc-tmp/"$SERIAL"-Serial.txt
    grep <swqc-tmp/fndebug/System/dump.txt "License(" | cut -d "'" -f 6 >swqc-tmp/"$SERIAL"-SerialHA.txt
    grep <swqc-tmp/fndebug/System/dump.txt "License(" | cut -d "'" -f 8 >swqc-tmp/"$SERIAL"-Customer-Name.txt
    grep <swqc-tmp/fndebug/System/dump.txt "License(" | cut -d "<" -f 2 | cut -d ":" -f 1 | cut -d "." -f 2 >swqc-tmp/"$SERIAL"-Contract-Type.txt
    grep <swqc-tmp/fndebug/System/dump.txt "License(" | cut -d "=" -f 10 | cut -d "," -f 1 >swqc-tmp/"$SERIAL"-Contract-Duration.txt
    LICENSEDUR=$(cat swqc-tmp/"$SERIAL"-Contract-Duration.txt)

    {
        echo -n "MODEL TYPE: " | cat - swqc-tmp/"$SERIAL"-Model-Type.txt
        echo -n "SERIAL NUMBER: " | cat - swqc-tmp/"$SERIAL"-Serial.txt
        echo -n "SERIAL NUMBER (HA): " | cat - swqc-tmp/"$SERIAL"-SerialHA.txt
        echo -n "CUSTOMER NAME: " | cat - swqc-tmp/"$SERIAL"-Customer-Name.txt
        echo -n "CONTRACT TYPE: " | cat - swqc-tmp/"$SERIAL"-Contract-Type.txt | tr '[:lower:]' '[:upper:]'
        echo -e "CONTRACT DURATION: "$((LICENSEDUR / 365)) "YEARS"
    } >>swqc-tmp/"$SERIAL"-License-Key-Info.txt
    LICENSEKEYINFO=$(cat swqc-tmp/"$SERIAL"-License-Key-Info.txt)
else
    echo "NOT SET" >>swqc-tmp/"$SERIAL"-License-Check.txt
    LICENSEKEYINFO=$(cat swqc-tmp/"$SERIAL"-Warning.txt)
fi
LICENSECHECK=$(cat swqc-tmp/"$SERIAL"-License-Check.txt)

#########################################################################################################

# Checking ZPOOL

zpool status >swqc-tmp/"$SERIAL"-ZPOOL-Status.txt
ZPOOLSTAT=$(cat swqc-tmp/"$SERIAL"-ZPOOL-Status.txt)

zpool status boot-pool >swqc-tmp/"$SERIAL"-Boot-Pool.txt
BOOTPOOL=$(cat swqc-tmp/"$SERIAL"-Boot-Pool.txt)

# Checking For MCA Errors

grep </var/log/messages -iC6 "MCA" | grep -i "Error" >swqc-tmp/"$SERIAL"-MCA-Errors.txt
MCARRORS=$(cat swqc-tmp/"$SERIAL"-MCA-Errors.txt)

# Logging Information

mcelog >swqc-tmp/"$SERIAL"-MCE-Log.txt
midclt call alert.list >swqc-tmp/"$SERIAL"-Alert-List.txt

#########################################################################################################

# Checking That S.M.A.R.T. Testing Is Set For HDD Pools

echo 'select * from tasks_smarttest' | sqlite3 /data/freenas-v1.db >swqc-tmp/"$SERIAL"-SMART-Out.txt
SMARTOUT=$(cat swqc-tmp/"$SERIAL"-SMART-Out.txt)

if cut <swqc-tmp/"$SERIAL"-SMART-Out.txt -d "|" -f 3 | grep -Fwqi -e "SHORT" && cut <swqc-tmp/"$SERIAL"-SMART-Out.txt -d "," -f 1-12 | grep -oh "\w*feb,mar,apr,may,jun,jul,aug,sep,oct,nov,dec|sat|0\w*" | grep -Fwqi -e "feb,mar,apr,may,jun,jul,aug,sep,oct,nov,dec|sat|0"; then
    echo "S.M.A.R.T. Test Correctly Set" >swqc-tmp/"$SERIAL"-SMART-Results.txt
else
    echo "S.M.A.R.T. Test Not Set" >swqc-tmp/"$SERIAL"-SMART-Results.txt
fi
SMARTCHECK=$(cat swqc-tmp/"$SERIAL"-SMART-Results.txt)

# Checking That SSH Is Enabled W/ ROOT Login

echo 'select ssh_rootlogin from services_ssh' | sqlite3 /data/freenas-v1.db >swqc-tmp/"$SERIAL"-SSHroot-Out.txt
SSHROOT=$(cat swqc-tmp/"$SERIAL"-SSHroot-Out.txt)

if [[ $SSHROOT -eq 1 ]]; then
    echo "SSH For ROOT Correctly Set" >swqc-tmp/"$SERIAL"-SSHroot-Results.txt
else
    echo "SSH For ROOT Not Set" >swqc-tmp/"$SERIAL"-SSHroot-Results.txt
fi
SSHCHECK=$(cat swqc-tmp/"$SERIAL"-SSHroot-Results.txt)

#########################################################################################################
#########################################################################################################

# Creating DIFFME File

{
    echo -e "IXSYSTEMS INC. SWQC COMPONENT & CONFIGURATION DIFF"
    echo -e "--------------------------------------------------\n\n"
    echo -e "SYSTEM SERIAL: $SERIAL\n"
    echo -e "PRODUCT NAME: $PRODUCT\n"
    echo -e "PRODUCT VERSION: $PVERSION\n"
    echo -e "TrueNAS VERSION: $TVERSION\n"
    echo -e "MOTHERBOARD INFO: $MOTHERBOARD\n"
    echo -e "MOTHERBOARD VERSION: $MBVERSION\n"
    echo -e "BIOS VERSION: $BIOVER\n"
    echo -e "$BIOSCHECK\n"
    echo -e "BMC VERSION: $BMCINFO\n"
    echo -e "$BMCCHECK\n"
    echo -e "HOSTNAME: $SYSHOSTNAME\n"
    echo -e "IPMI INFO:↴\n\n$IPMI\n"
    echo -e "ENCLOSURE INFO:↴\n\n$ENCLOSUREINFO\n"
    echo -e "CPU INFO:↴\n\n$CPU\n"
    echo -e "CPU COUNT: $CPUCOUNT\n"
    echo -e "MEMORY CAPACITY:↴\n\n$MEMCAP\n"
    echo -e "MEMORY COUNT: $MEMCOUNT\n"
    echo -e "TOTAL PHYSICAL MEMORY: $TPM\n"
    echo -e "PORT COUNT: $PORTCOUNT\n"
    if [[ -n "$ADDONCARD" ]]; then
        echo -e "ADD-ON CARDS:↴\n\n$ADDONCARD\n" >>swqc-tmp/3-iX-"$SERIAL"-DIFFME.txt
    fi
    echo -e "DRIVE COUNT: $DRIVECOUNT\n"
    echo -e "NVME DRIVE COUNT: $NVMEDRIVECOUNT\n"
    echo -e "DRIVE CAPACITY:↴\n\n$DRIVECAP\n"
    echo -e "RW CACHE DRIVE: $RWCACHECHECK\n"
    if [[ -n "$RWCACHECAP" ]]; then
        echo -e "RW CACHE CAPACITY:↴\n\n$RWCACHECAP\n" >>swqc-tmp/3-iX-"$SERIAL"-DIFFME.txt
    fi
    echo -e "BOOT POOL INFO:↴\n\n$BOOTPOOL\n"
    echo -e "BOOT DRIVE INFO:↴\n\n$BOOTDRIVE\n"
    echo -e "POWER SUPPLY STATE: $PWRSTATE\n"
    echo -e "POWER SUPPLY STATUS:↴\n\n$PSSDROUT\n"
    echo -e "TrueNAS LICENSE: $LICENSECHECK\n"
    if [[ -n "$LICENSEKEYINFO" ]]; then
        echo -e "TrueNAS LICENSE KEY INFO:↴\n\n$LICENSEKEYINFO\n" >>swqc-tmp/3-iX-"$SERIAL"-DIFFME.txt
    fi
    echo -e "S.M.A.R.T. TEST VERIFICATION: $SMARTCHECK\n"
    echo -e "SSH ROOT LOGIN VERIFICATION: $SSHCHECK\n"
    echo -e "SEL ERRORS:↴\n\n$SELINFO\n"
} >>swqc-tmp/3-iX-"$SERIAL"-DIFFME.txt

#########################################################################################################
#########################################################################################################

# Here We're Going To Rename Our Output Folder And Compress It.
# Then We're Going To Mount SJ-Storage In Order To Transfer Our Output Folder.

# Renaming Output File

cd /tmp || return
mv swqc-tmp/ "$SERIAL"-SWQC-OUT

# Creating .tar File From Output

tar cfz "$SERIAL-SWQC-OUT.tar.gz" "$SERIAL"-SWQC-OUT/

# Setting Up SJ-Storage For File Transfer

echo "Mounting SJ-Storage"
echo "[REPLACE_WITH_SERVER_ADDRESS:ROOT]" >~/.nsmbrc
echo "password=REPLACE_WITH_PASSWORD" >>~/.nsmbrc
cat ~/.nsmbrc
mkdir /mnt/sj-storage
mount_smbfs -N -I REPLACE_WITH_SERVER_IP //root@REPLACE_WITH_SERVER_IP/sj-storage/ /mnt/sj-storage/ || mount -t cifs -o vers=3,username=root,password=REPLACE_WITH_PASSWORD '//REPLACE_WITH_SERVER_IP/sj-storage/' /mnt/sj-storage/
cat /mnt/sj-storage/swqc-output/smbconnection-verified.txt >>swqc-tmp/swqc-output.txt
cat /mnt/sj-storage/swqc-output/smbconnection-verified.txt >swqc-tmp/smb-verified.txt
echo "SJ-Storage Mounted"

#########################################################################################################

# Sending Output Files to SJ-Storage

echo "Copying tar.gz File To swqc-output On SJ-Storage"

cd /tmp || return
cp -- *.tar.gz /mnt/sj-storage/swqc-output/

echo "Finished Copying tar.gz File To swqc-output On SJ-Storage"

# Clean Up
# Clearning Chassis Intrusion

ipmitool raw 0x30 0x03

# Clearing SEL Info

ipmitool sel clear

# Removing Temp Files

rm -rf "$SERIAL"-SWQC-OUT/
rm -rf "$SERIAL"-SWQC-OUT.tar.gz
unset HISTFILE
rm /root/.zsh-histfile

#reboot

exit
