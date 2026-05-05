#!/bin/bash
#########################################################################################################
# Title: SWQC-X20-HA.sh
# Description: SWQC For TrueNAS Systems After Client Configuration
# Author: jgarcia@ixsystems.com
# Updated: 05:02:2023
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

# Grabbing Motherboard Info (Redbook Pg. 4)

dmidecode -t2 | grep -Ei 'Product' | awk '{$1=$1};1' | cut -d " " -f 3- >swqc-tmp/"$SERIAL"-Motherboard-Info.txt
MOTHERBOARD=$(cat swqc-tmp/"$SERIAL"-Motherboard-Info.txt)

dmidecode -t2 | grep -EiA1 'Product|Version' | grep -i version | cut -d ":" -f 2 | xargs >swqc-tmp/"$SERIAL"-Motherboard-Version.txt
MBVERSION=$(cat swqc-tmp/"$SERIAL"-Motherboard-Version.txt)

dmidecode -t bios info | grep -i version | cut -d ":" -f 2 | xargs >swqc-tmp/"$SERIAL"-BIOS-Version.txt
BIOVER=$(cat swqc-tmp/"$SERIAL"-BIOS-Version.txt)

# TrueNAS R20B BIOS Firmware Check

if echo "$BIOVER" | grep -oh "\w*IXS.1.00.14\w*" | grep -Fwqi -e IXS.1.00.14; then
    echo "  - BIOS Version For $PRODUCT Is Correctly Showing As $BIOVER" >>swqc-tmp/"$SERIAL"-BIOS-Version-Check.txt
else
    echo "  - BIOS Version For $PRODUCT Is Showing As $BIOVER It Should Be IXS.1.00.14" >>swqc-tmp/"$SERIAL"-BIOS-Version-Check.txt
fi
BIOSCHECK=$(cat swqc-tmp/"$SERIAL"-BIOS-Version-Check.txt)

# Grabbing Enclosure Info

sesutil map | grep -Ei "Enclosure Name" | cut -d ":" -f 2 | awk '{$1=$1};1' >swqc-tmp/"$SERIAL"-Enclosure-Info.txt
ENCLOSUREINFO=$(cat swqc-tmp/"$SERIAL"-Enclosure-Info.txt)

sesutil map | grep -Ei "Enclosure Name" | cut -d ":" -f 2 | awk '{$1=$1};1' | head -n1 | cut -d " " -f3 >swqc-tmp/"$SERIAL"-Enclosure-Firmware.txt
ENCLOSUREFIRM=$(cat swqc-tmp/"$SERIAL"-Enclosure-Firmware.txt)

if echo "$ENCLOSUREFIRM" | grep -oh "\w*0403\w*" | grep -Fwqi -e 0403; then
    echo "  - SES Version For $PRODUCT Is Correctly Showing As $ENCLOSUREFIRM" >>swqc-tmp/"$SERIAL"-Enclosure-Firmware-Check.txt
else
    echo "  - SES Version For $PRODUCT Is Showing As $ENCLOSUREFIRM It Should Be 0403" >>swqc-tmp/"$SERIAL"-Enclosure-Firmware-Check.txt
fi
ENCLOSUREFIRMCHECK=$(cat swqc-tmp/"$SERIAL"-Enclosure-Firmware-Check.txt)

#########################################################################################################

# Getting HBA Info (Redbook Pg. 4)

sas3flash -listall >swqc-tmp/"$SERIAL"-SAS3-Info.txt
SAS3INFO=$(cat swqc-tmp/"$SERIAL"-SAS3-Info.txt)

sas3flash -list -c 0 >swqc-tmp/"$SERIAL"-SAS3-List.txt
SAS3LISTC0=$(cat swqc-tmp/"$SERIAL"-SAS3-List.txt)

sas3flash -list -c 1 >swqc-tmp/"$SERIAL"-SAS3-List.txt
SAS3LISTC1=$(cat swqc-tmp/"$SERIAL"-SAS3-List.txt)

# Getting Internal HBA Info (Redbook Pg. 4)

sas3flash -c 0 -list | grep -Ei 'Controller                     :' | cut -d "(" -f 1 | cut -d ":" -f 2 | xargs >swqc-tmp/"$SERIAL"-iHBA-Prod.txt
HBAPRODi=$(cat swqc-tmp/"$SERIAL"-iHBA-Prod.txt)

sas3flash -c 0 -list | grep -Ei 'Firmware Version ' | cut -d ":" -f 2 | xargs >swqc-tmp/"$SERIAL"-iHBA-Firmware.txt
HBAFIRMi=$(cat swqc-tmp/"$SERIAL"-iHBA-Firmware.txt)

sas3flash -c 0 -list | grep -Ei 'Firmware Product ID' | cut -d ":" -f 2 | cut -d "(" -f 2 | cut -d ")" -f 1 >swqc-tmp/"$SERIAL"-iHBA-ITCheck.txt
ITCHECKi=$(cat swqc-tmp/"$SERIAL"-iHBA-ITCheck.txt)

if [[ $HBAPRODi == SAS3008 ]] && [[ $HBAFIRMi == 14.00.00.00 ]] && [[ $ITCHECKi == IT ]]; then
    echo "$HBAPRODi Correctly Showing Firmware $HBAFIRMi & Is Flashed To $ITCHECKi" >swqc-tmp/"$SERIAL"-iHBA-Check.txt
else
    echo "[CHECK HBA: WRONG CONFIGURATION]" >swqc-tmp/"$SERIAL"-iHBA-Check.txt
fi
HBACHECKi=$(cat swqc-tmp/"$SERIAL"-iHBA-Check.txt)

# Getting External HBA Info (Redbook Pg. 4)

sas3flash -c 1 -list | grep -Ei 'Controller                     :' | cut -d "(" -f 1 | cut -d ":" -f 2 | xargs >swqc-tmp/"$SERIAL"-eHBA-Prod.txt
HBAPRODe=$(cat swqc-tmp/"$SERIAL"-eHBA-Prod.txt)

sas3flash -c 1 -list | grep -Ei 'Firmware Version ' | cut -d ":" -f 2 | xargs >swqc-tmp/"$SERIAL"-eHBA-Firmware.txt
HBAFIRMe=$(cat swqc-tmp/"$SERIAL"-eHBA-Firmware.txt)

sas3flash -c 1 -list | grep -Ei 'Firmware Product ID' | cut -d ":" -f 2 | cut -d "(" -f2 | cut -d ")" -f 1 >swqc-tmp/"$SERIAL"-eHBA-ITCheck.txt
ITCHECKe=$(cat swqc-tmp/"$SERIAL"-eHBA-ITCheck.txt)

if [[ $HBAPRODe == SAS3008 ]] && [[ $HBAFIRMe == 14.00.00.00 ]] && [[ $ITCHECKe == IT ]]; then
    echo "$HBAPRODe Correctly Showing Firmware $HBAFIRMe & Is Flashed To $ITCHECKe" >swqc-tmp/"$SERIAL"-eHBA-Check.txt
else
    echo "[CHECK HBA: WRONG CONFIGURATION]" >swqc-tmp/"$SERIAL"-eHBA-Check.txt
fi
HBACHECKe=$(cat swqc-tmp/"$SERIAL"-eHBA-Check.txt)

#########################################################################################################

# Getting CPU Info

dmidecode -t processor | grep -Ei 'CPU|Core|Version|Serial|Speed|Manufacturer' | awk '{$1=$1};1' >swqc-tmp/"$SERIAL"-CPU-Info.txt
CPU=$(cat swqc-tmp/"$SERIAL"-CPU-Info.txt)

dmidecode -t processor | grep -c 'CPU' >swqc-tmp/"$SERIAL"-CPU-Count.txt
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

#########################################################################################################

# Add-On NIC Check

# Checking For X540

if pciconf -lvcb | grep -oh "\w*X540\w*" | grep -Fwqi -e X540; then
    pciconf -lvcb | grep -i X540 | head -n 1 | cut -d "'" -f 2 >>swqc-tmp/"$SERIAL"-ADDON-NIC.txt
fi

# Checking For X710

if pciconf -lvcb | grep -oh "\w*X710\w*" | grep -Fwqi -e X710; then
    pciconf -lvcb | grep -i X710 | head -n 1 | cut -d "'" -f 2 >>swqc-tmp/"$SERIAL"-ADDON-NIC.txt
fi

# Checking For T520

if pciconf -lvcb | grep -oh "\w*T520\w*" | grep -Fwqi -e T520; then
    pciconf -lvcb | grep -i T520 | head -n 1 | cut -d "'" -f 2 >>swqc-tmp/"$SERIAL"-ADDON-NIC.txt
fi

# Checking For T580

if pciconf -lvcb | grep -oh "\w*T580\w*" | grep -Fwqi -e T580; then
    pciconf -lvcb | grep -i T580 | head -n 1 | cut -d "'" -f 2 >>swqc-tmp/"$SERIAL"-ADDON-NIC.txt
fi

# Checking For i350

if pciconf -lvcb | grep -oh "\w*i350\w*" | grep -Fwqi -e i350; then
    pciconf -lvcb | grep -i i350 | head -n 1 | cut -d "'" -f 2 >>swqc-tmp/"$SERIAL"-ADDON-NIC.txt
fi

# Checking For QLE2562

if pciconf -lvcb | grep -oh "\w*QLE2562\w*" | grep -Fwqi -e QLE2562; then
    pciconf -lvcb | grep -i QLE2562 | head -n 1 | cut -d "'" -f 2 >>swqc-tmp/"$SERIAL"-ADDON-NIC.txt
fi

# Checking For T6225

if pciconf -lvcb | grep -oh "\w*T6225\w*" | grep -Fwqi -e T6225; then
    pciconf -lvcb | grep -i T6225 | head -n 1 | cut -d "'" -f 2 >>swqc-tmp/"$SERIAL"-ADDON-NIC.txt
fi

ADDONCARDS=$(cat swqc-tmp/"$SERIAL"-ADDON-NIC.txt)

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

smartctl -x /dev/nvme* | grep -i /dev | cut -d/ -f 3 | grep -iv "ns1" >swqc-tmp/"$SERIAL"-NVME-Info.txt
NVMEDRIVES=$(cat swqc-tmp/"$SERIAL"-NVME-Info.txt)

# Grabbing NVME Count

smartctl -x /dev/nvme* | grep -i /dev | cut -d/ -f 3 | grep -cv "ns1" >swqc-tmp/"$SERIAL"-NVME-Count.txt
NVMEDRIVECOUNT=$(cat swqc-tmp/"$SERIAL"-NVME-Count.txt)

# Grabbing SMART Info

camcontrol devlist | cut -d, -f 2 | tr -d \) | grep -v "ses" | xargs -I DRIVE smartctl -x /dev/DRIVE >swqc-tmp/"$SERIAL"-SMART-Info.txt
SMARTOUT=$(cat swqc-tmp/"$SERIAL"-SMART-Info.txt)

# Grabbing Drive Capacity

camcontrol devlist | cut -d, -f 2 | tr -d \) | grep -v "ses" | xargs -I DRIVE smartctl -x /dev/DRIVE | grep -Ei "Device Model|Serial Number|User Capacity|Product" | grep -Ev TrueNAS >swqc-tmp/"$SERIAL"-Drive-Capacity.txt
DRIVECAP=$(cat swqc-tmp/"$SERIAL"-Drive-Capacity.txt)

camcontrol devlist | cut -d, -f2 | tr -d \) | grep -v "ses" | xargs -I DRIVE smartctl -A /dev/DRIVE | grep -i "Current Drive Temperature" >swqc-tmp/"$SERIAL"-Drive-Temp.txt
DRIVETEMP=$(cat swqc-tmp/"$SERIAL"-Drive-Temp.txt)

# Getting Boot Device Info (Redbook Pg. 15)

camcontrol devlist | grep -i "SATA Flash Drive" | awk '{$1=$1};1' >swqc-tmp/"$SERIAL"-Boot-Device.txt
BOOTDRIVE=$(cat swqc-tmp/"$SERIAL"-Boot-Device.txt)

#########################################################################################################

# Get Sensor Output Information

dmidecode -t chassis | grep -i "Power Supply State:" | cut -d " " -f 4 >swqc-tmp/"$SERIAL"-PWR-State.txt
PWRSTATE=$(cat swqc-tmp/"$SERIAL"-PWR-State.txt)

#########################################################################################################

# Getting Read/Write Cache Drive Info (Redbook Pg. 15)

camcontrol devlist | grep -i "MTFDDAK960TDS" | cut -d, -f2 | tr -d \) | grep -v ses | xargs -I DRIVE smartctl -x /dev/DRIVE | grep -Ei "Device Model|Serial Number|User Capacity" || camcontrol devlist | grep -i "Micron 5300 MTFDDAK480TDS" | cut -d, -f2 | tr -d \) | grep -v ses | xargs -I DRIVE smartctl -x /dev/DRIVE | grep -Ei "Device Model|Serial Number|User Capacity" || camcontrol devlist | grep -i "XS960SE70055" | cut -d, -f2 | tr -d \) | grep -v ses | xargs -I DRIVE smartctl -x /dev/DRIVE | grep -Ei "Device Model|Serial Number|User Capacity" >>swqc-tmp/"$SERIAL"-RW-Cache.txt
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
    echo "SMART Test Correctly Set" >swqc-tmp/"$SERIAL"-SMART-Results.txt
else
    echo "SMART Test Not Set" >swqc-tmp/"$SERIAL"-SMART-Results.txt
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
    echo -e "HOSTNAME: $SYSHOSTNAME\n"
    echo -e "ENCLOSURE INFO:↴\n\n$ENCLOSUREINFO\n"
    echo -e "$ENCLOSUREFIRMCHECK\n"
    echo -e "SAS3 INFO:↴\n\n$SAS3INFO\n"
    echo -e "SAS3 LIST:↴\n\n$SAS3LISTC0\n"
    if echo "$SAS3LISTC1" | grep -oh "\w*SAS3008\w*" | grep -Fwqi -e SAS3008; then
        echo -e "\n$SAS3LISTC1\n" >>swqc-tmp/3-iX-"$SERIAL"-DIFFME.txt
    fi
    echo -e "INTERNAL HBA FIRMWARE: $HBAFIRMi\n"
    echo -e "INTERNAL HBA CHECK: $HBACHECKi\n"
    if [[ -n "$HBAPRODe" ]]; then
        echo -e "EXTERNAL HBA FIRMWARE: $HBAFIRMe\n" >>swqc-tmp/3-iX-"$SERIAL"-DIFFME.txt
        echo -e "EXTERNAL HBA CHECK: $HBACHECKe\n" >>swqc-tmp/3-iX-"$SERIAL"-DIFFME.txt
    fi
    echo -e "CPU INFO:↴\n\n$CPU\n"
    echo -e "CPU COUNT: $CPUCOUNT\n"
    echo -e "MEMORY CAPACITY:↴\n\n$MEMCAP\n"
    echo -e "MEMORY COUNT: $MEMCOUNT\n"
    echo -e "TOTAL PHYSICAL MEMORY: $TPM\n"
    echo -e "PORT COUNT: $PORTCOUNT\n"
    if [[ -n "$ADDONCARDS" ]]; then
        echo -e "ADD-ON CARDS:↴\n\n$ADDONCARDS\n" >>swqc-tmp/3-iX-"$SERIAL"-DIFFME.txt
    fi
    echo -e "DRIVE COUNT: $DRIVECOUNT\n"
    echo -e "NVME DRIVE COUNT: $NVMEDRIVECOUNT\n"
    echo -e "DRIVE CAPACITY:↴\n\n$DRIVECAP\n"
    echo -e "RW CACHE DRIVE: $RWCACHECHECK\n"
    if [[ -n "$RWCACHECAP" ]]; then
        echo -e "RW CACHE CAPACITY:↴\n\n$RWCACHECAP\n"
    fi
    echo -e "BOOT POOL INFO:↴\n\n$BOOTPOOL\n"
    echo -e "BOOT DRIVE INFO:↴\n\n$BOOTDRIVE\n"
    echo -e "POWER SUPPLY STATE: $PWRSTATE\n"
    echo -e "TrueNAS LICENSE: $LICENSECHECK\n"
    if [[ -n "$LICENSECHECK" ]]; then
        echo -e "TrueNAS LICENSE KEY INFO:↴\n\n$LICENSEKEYINFO\n" >>swqc-tmp/3-iX-"$SERIAL"-DIFFME.txt
    fi
    echo -e "S.M.A.R.T. TEST VERIFICATION: $SMARTCHECK\n"
    echo -e "SSH ROOT LOGIN VERIFICATION: $SSHCHECK\n"
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
echo "[REPLACE_WITH_SERVER_ADDRESS:ROOT]" > ~/.nsmbrc
echo "password=REPLACE_WITH_PASSWORD" >> ~/.nsmbrc
cat ~/.nsmbrc
mkdir /mnt/sj-storage
mount_smbfs -N -I REPLACE_WITH_SERVER_IP //root@REPLACE_WITH_SERVER_IP/sj-storage/ /mnt/sj-storage/ || mount -t cifs -o vers=3,username=root,password=REPLACE_WITH_PASSWORD '//REPLACE_WITH_SERVER_IP/sj-storage/' /mnt/sj-storage/
cat /mnt/sj-storage/swqc-output/smbconnection-verified.txt >> swqc-tmp/swqc-output.txt
cat /mnt/sj-storage/swqc-output/smbconnection-verified.txt > swqc-tmp/smb-verified.txt
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
