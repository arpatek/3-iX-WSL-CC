#!/bin/sh 
#####################################################################################
# title			:swqc-check-remote.sh
# description		:SWQC Valadat check of parts and system config of TrueNAS Systems 
# author		:Jason Browne
# date			:07:15:2020
# version		: 0.1
#####################################################################################
#
# 
# Directions: Step 1 Within same directory as sim-check-remote.sh 
#
# create txtfile with list of TrueNAS GUI ips file called ip.txt 
#
# one line per ip
#####################################################################################
#
# 
#
#
# Step 2
# 
# Collection folder
# Making temp file for swqc check txt
# This is directory where the data we collect will go
#
cd /tmp 
mkdir swqc-tmp
#
touch swqc-tmp/warning.txt
touch swqc-tmp/swqc-output.txt
touch swqc-tmp/serialnumber-output.txt
touch swqc-tmp/parts-list.txt
touch swqc-tmp/$SERIAL-PorF.txt
#
#
#
#
#####################################################################################
#
#
# step 3 
# 
# run script:
# two ways direcly or remotly using run-sim-check-remote.sh
#
# method 1:
#
# a. run 
# cat sim-check-remote.sh | sshpass -vp <TRUENAS_ROOT_PASSWORD> ssh -tt -oStrictHostKeyChecking=no root@<True Gui ip> -yes
# b. Collect output from data collection folder
#
# Method 2: 
#
# run via sim-check-remote.sh
# a. Etner TrueNAS Gui ips of systems you wish to valadate into ip.txt
# b. Run sim-check-remote.sh 
# c. Collect output from data collection folder 
######################################################################################
#
cd /tmp
#
echo "Collecting Serial Number:" >> swqc-tmp/swqc-output.txt
#
# 
#
#
#
dmidecode -t1 | grep -i serial >> swqc-tmp/swqc-output.txt
#
dmidecode -t1 | grep -Eoi "A1-.{0,6}" | head -n 1 >> swqc-tmp/serialnumber-output.txt
#
#
SERIAL=$( cat swqc-tmp/serialnumber-output.txt)
#
echo "Your systems serial number is $SERIAL" 
echo "Your systems serial number is $SERIAL" >> swqc-tmp/swqc-output.txt
touch swqc-tmp/$SERIAL-part-count.txt
touch swqc-tmp/$SERIAL-diffme.txt
#
#
#
#
#
echo " Product description " >> swqc-tmp/swqc-output.txt
#
#
echo "Verify system is tagged correctly and has the correct version" >> swqc-tmp/swqc-output.txt
#
#
# Get Product Name
#
#
dmidecode -t1 | grep -i --color "Product Name" >> swqc-tmp/swqc-output.txt
#
dmidecode -t1 | grep -i --color "Product Name"  > swqc-tmp/product-output.txt
#
#
PRODUCT=$( cat swqc-tmp/product-output.txt)
#
#
#
echo "===============================" >> swqc-tmp/$SERIAL-part-count.txt
echo "===============================" >> swqc-tmp/$SERIAL-part-count.txt
#
echo "Product" >> swqc-tmp/$SERIAL-part-count.txt
#
#
echo "$PRODUCT" >> swqc-tmp/$SERIAL-part-count.txt
#
echo "Product" >> swqc-tmp/$SERIAL-diffme.txt
#
echo "$PRODUCT" >> swqc-tmp/$SERIAL-diffme.txt
#
#
echo "Product" >> swqc-tmp/$SERIAL-PorF.txt
echo "$PRODUCT" >> swqc-tmp/$SERIAL-PorF.txt
#
#
dmidecode -t1 | grep -i version >> swqc-tmp/swqc-output.txt
#
dmidecode -t1 | grep -i version > swqc-tmp/pversion-output.txt
#
#
PVERSION=$( cat swqc-tmp/pversion-output.txt)
#
echo "Product Version" >> swqc-tmp/$SERIAL-part-count.txt
echo "$PVERSION" >> swqc-tmp/$SERIAL-part-count.txt
#
#
echo "Product Version" >> swqc-tmp/$SERIAL-diffme.txt
echo "$PVERSION" >> swqc-tmp/$SERIAL-diffme.txt
#
#
echo "Product Version" >> swqc-tmp/$SERIAL-PorF.txt
echo "Product Version" >> swqc-tmp/$SERIAL-PorF.txt
#
#
echo "===============================" >> swqc-tmp/$SERIAL-part-count.txt
echo "===============================" >> swqc-tmp/swqc-output.txt
#
#
#
# Get TrueNAS version:
#
#echo  "Retreiving TrueNAS verson"
#
#
cat  /etc/version >> swqc-tmp/swqc-output.txt
#
cat /etc/version > swqc-tmp/version-output.txt
#
#
VERSION=$( cat swqc-tmp/version-output.txt)
#
echo "TrueNAS Version" >> swqc-tmp/$SERIAL-part-count.txt
echo "$VERSION" >> swqc-tmp/$SERIAL-part-count.txt
#
#
echo "TrueNAS Version" >> swqc-tmp/$SERIAL-diffme.txt
echo "$VERSION" >> swqc-tmp/$SERIAL-diffme.txt
#
#
#
echo "TrueNAS Version" >> swqc-tmp/$SERIAL-PorF.txt
echo "$VERSION"  >> swqc-tmp/$SERIAL-PorF.txt
#
#
#
#
echo "===============================" >> swqc-tmp/swqc-output.txt
#
#
#
echo "Checking for TrueNAS License " >> swqc-tmp/swqc-output.txt
echo "Checking for TrueNAS License " >> swqc-tmp/$SERIAL-PorF.txt
#
#
cat /data/license >> swqc-tmp/swqc-output.txt
cat /data/license >  swqc-tmp/license.txt
#
LICENSE=$(cat swqc-tmp/license.txt)
#
echo "TrueNAS License" >> swqc-tmp/$SERIAL-part-count.txt
#
echo "$LICENSE" >> swqc-tmp/$SERIAL-part-count.txt
#
echo "===============================" >> swqc-tmp/$SERIAL-part-count.txt
echo "===============================" >> swqc-tmp/$SERIAL-part-count.txt
#
#
echo "===============================" >> swqc-tmp/swqc-output.txt
#
# Get Start time and date of SWQC Check 
#
#
date > swqc-tmp/start-time-output.txt
date >> swqc-tmp/swqc-output.txt
#
#
echo "===============================" >> swqc-tmp/swqc-output.txt
#
#
# if echo "$PRODUCT" | grep -oh "\w*HA\w*"| grep -Fwqi -e HA ; then
#
#
#echo "Enter Node"
#
# dialog --inputbox "Enter Node SWQC Test is being performed on" 10 60 2>swqc-tmp/nodetemp.txt
#
# NODE=$( cat swqc-tmp/nodetemp.txt ) 
#
# cat swqc-tmp/nodetemp.txt >> swqc-tmp/swqc-output.txt
#
#
# echo “Your entered $NODE”
#
#fi
#
echo "===============================" >> swqc-tmp/swqc-output.txt
#
#
STARTTIME=$( cat swqc-tmp/start-time-output.txt)
#
# echo " $SWQCPERSON commencing SWQC on: \ $PRODUCT \ $ORDER Number \ $SERIAL \ at $STARTTIME "
#
#
#
# printf %"$COLUMNS"s |tr " " "#" >> swqc-tmp/swqc-output.txt
#
#echo “ $SWQCPERSON commencing SWQC on $PRODUCT \ $ORDER Number \ Serial Number: $SERIAL \ Start Time: $STARTTIME “ >> swqc-tmp/swqc-output.txt
#printf %"$COLUMNS"s |tr " " "#" >> swqc-tmp/swqc-output.txt
#
#
#
#
#
echo "===============================" >> swqc-tmp/swqc-output.txt
#
#
#
#
#
echo "Motherboard, Memory, and CPU information" >> swqc-tmp/swqc-output.txt
#
#
#
#
# Verify that the motherboard and version are correct:
#
# 
#
#
#
echo "Verify that the motherboard and version are correct" >> swqc-tmp/swqc-output.txt
echo "Check that the bios is the correct version for this motherboard" >> swqc-tmp/swqc-output.txt
#
#
#
#
dmidecode -t2 | grep -EiA1 --color 'Product|Version' >> swqc-tmp/swqc-output.txt
#
dmidecode -t2 | grep -EiA1 --color 'Product|Version' > swqc-tmp/motherboard-output.txt
#
#
MOTHERBOARD=$( cat swqc-tmp/motherboard-output.txt)
#
#
echo "===============================" >> swqc-tmp/$SERIAL-part-count.txt
#
#
# echo "The product name and version of your motherboard is $MOTHERBOARD"
#
#
echo "Motherboard" >> swqc-tmp/$SERIAL-part-count.txt
#
echo "$MOTHERBOARD" >> swqc-tmp/$SERIAL-part-count.txt
#
#
echo "===============================" >> swqc-tmp/$SERIAL-part-count.txt
echo "===============================" >> swqc-tmp/$SERIAL-part-count.txt
#
#
# Get BIOS version and verify that it is the correct version for this motherboard
#
#
dmidecode -t bios info | grep -i version >> swqc-tmp/swqc-output.txt
#
dmidecode -t bios info | grep -i version > swqc-tmp/biosversion-output.txt
#
#
BIOVER=$( cat swqc-tmp/biosversion-output.txt)
#
#
echo "Bios Verison" >> swqc-tmp/$SERIAL-part-count.txt
#
echo "$BIOVER" >> swqc-tmp/$SERIAL-part-count.txt
#
#
# Get BMC info 
#
#
echo "Make sure that the IPMI has the crrect firmware" >> swqc-tmp/swqc-output.txt
#
#
ipmitool bmc info | grep -i "firmware revision" >> swqc-tmp/swqc-output.txt
#
ipmitool bmc info | grep -i "firmware revision" > swqc-tmp/bmc-output.txt
#
#
BMCINFO=$( cat swqc-tmp/bmc-output.txt)
#
#
echo " IMPI BMC Version" >> swqc-tmp/$SERIAL-part-count.txt
#
#
echo "$BMCINFO" >> swqc-tmp/$SERIAL-part-count.txt
#
#
echo "===============================" >> swqc-tmp/$SERIAL-part-count.txt
echo "===============================" >> swqc-tmp/$SERIAL-part-count.txt
#
#
echo "===============================" >> swqc-tmp/swqc-output.txt
#
# Enclosure Information
#
sesutil map| more| grep -Ei "Enclosure Name" >> swqc-tmp/swqc-output.txt
sesutil map| more| grep -Ei "Enclosure Name" > swqc-tmp/enclosure-info.txt
#
ENCLOSUREINFO=$(cat swqc-tmp/enclosure-info.txt)
#
echo " Ecnlosure Name" >> swqc-tmp/$SERIAL-part-count.txt
echo "$ENCLOSUREINFO" >> swqc-tmp/$SERIAL-part-count.txt
#
echo "===============================" >> swqc-tmp/swqc-output.txt
#
#
echo " HBA information " >> swqc-tmp/swqc-output.txt
#
sas3flash -listall >> swqc-tmp/swqc-output.txt
sas3flash -listall > swqc-tmp/sas3flashall-output.txt
#
SAS3FLASHAINFO=$(cat swqc-tmp/sas3flashall-output.txt)
#
#
echo "HBA Information" >> swqc-tmp/$SERIAL-part-count.txt
#
sas3flash -list >> swqc-tmp/swqc-output.txt
sas3flash -list > swqc-tmp/sas3flash-list-ouput.txt
#
SAS3FLASHLINFO=$(cat swqc-tmp/sas3flash-list-ouput.txt)
#
#
echo "$SAS3FLASHLINFO" >> swqc-tmp/$SERIAL-part-count.txt
#
echo "===============================" >> swqc-tmp/$SERIAL-part-count.txt
#
# sas3flash does not output the 9500-16e HBA so we can check its presence with storcli
# 
storcli /0 showall > swqc-tmp/storcli-showall.txt
storcli /all show > swqc/tmp/storcli-all-show.txt
#
#
echo "===============================" >> swqc-tmp/swqc-output.txt
#
# Verify Correct CPU and Number
#
#
# echo "Retrieving list of installed CPU’s"
#
#
echo "Check for the correct CPU quanity " >> swqc-tmp/swqc-output.txt
#
#
dmidecode -t processor | grep -Ei 'cpu|core|version|serial|speed|manufacturer' >> swqc-tmp/swqc-output.txt
#
dmidecode -t processor | grep -Ei 'cpu|core|version|serial|speed|manufacturer' > swqc-tmp/cpu-output.txt
#
#
CPU=$( cat swqc-tmp/cpu-output.txt)
#
#
echo "CPU Information" >> swqc-tmp/$SERIAL-part-count.txt
#
#
echo "$CPU" >> swqc-tmp/$SERIAL-part-count.txt
#
echo "===============================" >> swqc-tmp/$SERIAL-part-count.txt
echo "===============================" >> swqc-tmp/$SERIAL-part-count.txt
#
#
#
#
# Verify that Memory is correct 
#
#
#
#
echo "Check the Memory model speed and count against the work order" >> swqc-tmp/swqc-output.txt
#
#
#
#
dmidecode -t memory | grep -Ei 'manufacturer|serial|size|speed|locator' >> swqc-tmp/swqc-output.txt
dmidecode -t memory | grep -Ei 'manufacturer|serial|size|speed|locator' > swqc-tmp/meminfo-output.txt
#
#
MEMINFO=$( cat swqc-tmp/meminfo-output.txt)
#
#
echo "Memory information" >> swqc-tmp/$SERIAL-part-count.txt
#
echo "$MEMINFO" >> swqc-tmp/$SERIAL-part-count.txt
#
# check total physical memory for each node / system ensure that they match each other and the work order
#
sysctl -n hw.physmem | awk '{ byte =$1 /1024/1024/1024; print byte " GB" }' >> swqc-tmp/swqc-output.txt
sysctl -n hw.physmem | awk '{ byte =$1 /1024/1024/1024; print byte " GB" }' > swqc-tmp/total-physical-memory.txt
#
TPM=$(cat swqc-tmp/total-physical-memory.txt)
#
#
#
echo "Total Physical Memory" >> swqc-tmp/$SERIAL-part-count.txt
#
echo "$TPM" >> swqc-tmp/$SERIAL-part-count.txt
#
#
echo "Total Physical Memory" >> swqc-tmp/$SERIAL-diffme.txt
#
echo "$TPM" >> swqc-tmp/$SERIAL-diffme.txt
#
#
#
echo "===============================" >> swqc-tmp/swqc-output.txt
echo "===============================" >> swqc-tmp/$SERIAL-part-count.txt
echo "===============================" >> swqc-tmp/$SERIAL-part-count.txt
#
#
echo "Network Card information" >> swqc-tmp/swqc-output.txt
#
#
echo "Network Card Information" >> swqc-tmp/$SERIAL-part-count.txt
#
echo "Verify the correct NIC cards are installed" >> swqc-tmp/swqc-output.txt
#
#
dmesg | grep -Ei --color "Ethernet|Network" >> swqc-tmp/swqc-output.txt
dmesg | grep -Ei --color "Ethernet|Network" > swqc-tmp/nic-output.txt
#
#
NICS=$( cat swqc-tmp/nic-output.txt)
#
#
echo "$NICS" >> swqc-tmp/$SERIAL-part-count.txt
#
#
#
# verify that the nic ports match their interface names
#
# 
# list of ports 
#
ifconfig -a | sed 's/[ \t].*//;/^$/d'>> swqc-tmp/swqc-output.txt
ifconfig -a | sed 's/[ \t].*//;/^$/d'> swqc-tmp/ports.txt
#
PORTS=$(cat swqc-tmp/ports.txt)
#
#
echo "Ports" >> swqc-tmp/$SERIAL-part-count.txt
#
cat "$PORTS" >> swqc-tmp/$SERIAL-part-count.txt
#
#
ifconfig -a >> swqc-tmp/swqc-output.txt
ifconfig -a > swqc-tmp/ifconfig-output.txt
#
PORTINFO=$( cat swqc-tmp/ifconfig-output.txt)
#
#
#
echo "$PORTINFO" >> swqc-tmp/$SERIAL-part-count.txt
#
#
#
#
# Ensure the network port count matches the order:
#
#
echo "Port Count " >> swqc-tmp/swqc-output.txt
#
ifconfig -a |sed 's/[ \t].*//;/^$/d'|grep -Eiv "lo0|pflog0"| wc -l >> swqc-tmp/swqc-output.txt
ifconfig -a |sed 's/[ \t].*//;/^$/d'|grep -Eiv "lo0|pflog0"| wc -l > swqc-tmp/portcount-output.txt
#
#
PORTCOUNT=$( cat swqc-tmp/portcount-output.txt)
#
echo "Port Count" >> swqc-tmp/$SERIAL-part-count.txt
echo "$PORTCOUNT" >> swqc-tmp/$SERIAL-part-count.txt
echo "Port Count" >> swqc-tmp/$SERIAL-diffme.txt
echo "$PORTCOUNT" >> swqc-tmp/$SERIAL-diffme.txt
# 
# 
echo "===============================" >> swqc-tmp/swqc-output.txt
echo "===============================" >> swqc-tmp/$SERIAL-part-count.txt
#
#
echo " Network Settings " >> swqc-tmp/swqc-output.txt
# 
#
echo " hostname " >> swqc-tmp/swqc-output.txt
hostname >> swqc-tmp/swqc-output.txt
hostname > swqc-tmp/hostname-out.txt
#
#
SYSHOSTNAME=$(cat swqc-tmp/hostname-out.txt)
#
#
echo " gateway / default route " >> swqc-tmp/swqc-output.txt
netstat -rn | grep -i "default" >> swqc-tmp/swqc-output.txt
netstat -rn | grep -i "default" > swqc-tmp/default-route.txt
#
defaultroute=$(cat swqc-tmp/default-route.txt)
#
#
echo " Domain name servers " >> swqc-tmp/swqc-output.txt
cat /etc/resolv.conf >> swqc-tmp/swqc-output.txt
cat /etc/resolv.conf > swqc-tmp/dns-out.txt
#
DNSSERVERS=$(cat swqc-tmp/dns-out.txt)
#
#
echo " ip settings " >> swqc-tmp/swqc-output.txt
ifconfig -a >> swqc-tmp/swqc-output.txt
#
#
echo "ipmi network settings " >> swqc-tmp/swqc-output.txt
ipmitool lan print >> swqc-tmp/swqc-output.txt
ipmitool lan print > swqc-tmp/ipmi-out.txt
#
IPMI=$(cat swqc-tmp/ipmi-out.txt)
#
echo "===============================" >> swqc-tmp/swqc-output.txt
#
#
#
echo "===============================" >> swqc-tmp/$SERIAL-part-count.txt
#
echo "Hard Drive and SSD information " >> swqc-tmp/swqc-output.txt
#
echo "check the model, drive count, and firmware version " >> swqc-tmp/swqc-output.txt
#
echo "Hard Drive and SSD Information" >> swqc-tmp/$SERIAL-part-count.txt
#
camcontrol devlist >> swqc-tmp/swqc-output.txt
camcontrol devlist > swqc-tmp/cam-output.txt
#
#
CAM=$( cat swqc-tmp/cam-output.txt)
#
#
echo "$CAM" >> swqc-tmp/$SERIAL-part-count.txt
#

echo "drive count" >> swqc-tmp/swqc-output.txt
#
camcontrol devlist |grep -iv AHCI|grep -iv virtual|grep -E -o -i "pass.{0,6}" | cut -f2 -d, |wc -l >> swqc-tmp/swqc-output.txt
camcontrol devlist |grep -iv AHCI|grep -iv virtual|grep -E -o -i "pass.{0,6}" | cut -f2 -d, |wc -l > swqc-tmp/drivecount-output.txt
#
#
DRIVECOUNT=$(cat swqc-tmp/drivecount-output.txt)
#
#
echo "Drive Count" >> swqc-tmp/$SERIAL-part-count.txt
echo "Drive Count" >> swqc-tmp/$SERIAL-diffme.txt
#
echo "$DRIVECOUNT" >> swqc-tmp/$SERIAL-part-count.txt
echo "$DRIVECOUNT" >> swqc-tmp/$SERIAL-diffme.txt
#
#
echo "===============================" >> swqc-tmp/swqc-output.txt
#
echo "NVME Drives" >> swqc-tmp/swqc-output.txt
echo "NVME Drives" >> swqc-tmp/$SERIAL-part-count.txt
#
#
smartctl -x /dev/nvme* | grep -i /dev | cut -d/ -f3 | grep -iv ns1 >> swqc-tmp/swqc-output.txt
smartctl -x /dev/nvme* | grep -i /dev | cut -d/ -f3 | grep -iv ns1 >> swqc-tmp/$SERIAL-part-count.txt
smartctl -x /dev/nvme* | grep -i /dev | cut -d/ -f3 | grep -iv ns1 > swqc-tmp/nvmedrives.txt
#
NVMEDRIVES=$(cat swqc-tmp/nvmedrives.txt)
#
#
cat swqc-tmp/nvmedrives.txt | wc -l > swqc-tmp/nvmedrive-count.txt
#
#
NVMEDRIVECOUNT=$(cat swqc-tmp/nvmedrive-count.txt)
#
#
echo "NVME Drive Count" >> swqc-tmp/$SERIAL-part-count.txt
echo "$NVMEDRIVECOUNT"  >> swqc-tmp/$SERIAL-part-count.txt
echo "NVME Drive Count" >> swqc-tmp/$SERIAL-diffme.txt
echo "$NVMEDRIVECOUNT"  >> swqc-tmp/$SERIAL-diffme.txt
#
#
echo "===============================" >> swqc-tmp/swqc-output.txt
#
#
echo "device names" >> swqc-tmp/swqc-output.txt
#
#
camcontrol devlist |grep -v AHCI|grep -iv virtual|grep -E -o -i "pass.{0,6}" | cut -f2 -d, >> swqc-tmp/swqc-output.txt
camcontrol devlist |grep -v AHCI|grep -iv virtual|grep -E -o -i "pass.{0,6}" | cut -f2 -d, > swqc-tmp/devnames.txt
#
#
DEVNAMES=$(cat swqc-tmp/devnames.txt)
#
#
echo " Device Names" >> swqc-tmp/$SERIAL-part-count.txt
# 
echo "$DEVNAMES" >> swqc-tmp/$SERIAL-part-count.txt
#
# camcontrol devlist | grep -i < enter firmware number> | wc -l 
#
# example - camcontrol devlist | grep -i b450 | wc -l 
#
echo "===============================" >> swqc-tmp/$SERIAL-part-count.txt
echo "===============================" >> swqc-tmp/$SERIAL-part-count.txt
#
echo " Smart Info " >> swqc-tmp/swqc-output.txt 
#
#
camcontrol devlist | cut -d, -f2 | tr -d \) | grep -v ses | xargs -I DRIVE smartctl -x /dev/DRIVE >> swqc-tmp/swqc-output.txt
camcontrol devlist | cut -d, -f2 | tr -d \) | grep -v ses | xargs -I DRIVE smartctl -x /dev/DRIVE > swqc-tmp/smartout.txt
#
#
SMARTOUT=$(cat swqc-tmp/smartout.txt)
#
echo "Capacity of each Drive" >> swqc-tmp/swqc-output.txt
#
# for drive in $(camcontrol devlist| grep -iv virtual | cut -f2 -d\( | tr -d ')')
# do
#  prefix=$(echo $drive | cut -f1 -d, | cut -c1-2)
# field1=$(echo $drive | cut -f2 -d,)
# field2=$(echo $drive | cut -f2 -d,)
# echo "$field1  - $field2"
# echo -n "$drive - "
# smartctl -x /dev/$drive | grep -i capacity >> swqc-tmp/swqc-output.txt
# smartctl -x /dev/$drive | grep -i capacity > swqc-tmp/drivecap-output.txt
# smartctl -x /dev/$drive >> swqc-tmp/mysmart-out.txt
#
# DRIVECAP=$(cat swqc-tmp/drivecap-output.txt)
# done
#
camcontrol devlist | cut -d, -f2 | tr -d \) | grep -v ses | xargs -I DRIVE smartctl -x /dev/DRIVE | grep -Ei "device model|serial number|user capacity|product" | grep -Ev TrueNAS  >> swqc-tmp/swqc-output.txt
camcontrol devlist | cut -d, -f2 | tr -d \) | grep -v ses | xargs -I DRIVE smartctl -x /dev/DRIVE | grep -Ei "device model|serial number|user capacity|product" | grep -Ev TrueNAS  > swqc-tmp/drivecap-output.txt
#
#
DRIVECAP=$(cat swqc-tmp/drivecap-output.txt)
#
#
echo "Drive Capacity" >> swqc-tmp/$SERIAL-part-count.txt
#
#
echo "$DRIVECAP" >> swqc-tmp/$SERIAL-part-count.txt
#
echo "===============================" >> swqc-tmp/swqc-output.txt
#
#
if echo "$PRODUCT" | grep -Eqi 'TRUENAS-MINI'; then
#
echo "READ / Write Cache capacity check"  >> swqc-tmp/$SERIAL-part-count.txt
echo "READ / Write Cache capacity check" >> swqc-tmp/$SERIAL-diffme.txt
camcontrol devlist | grep -i "Micron 5300 MTFDDAK480TDS" | cut -d, -f 2 | tr -d \) | grep -v "ses" | xargs -I DRIVE smartctl -x /dev/DRIVE | grep -Ei "Device Model|Serial Number|User Capacity"  >> swqc-tmp/$SERIAL-part-count.txt
camcontrol devlist | grep -i "Micron 5300 MTFDDAK480TDS" | cut -d, -f 2 | tr -d \) | grep -v "ses" | xargs -I DRIVE smartctl -x /dev/DRIVE | grep -Ei "Device Model|Serial Number|User Capacity" >> swqc-tmp/$SERIAL-diffme.txt
#
#
fi
#
#
if echo "$PRODUCT" | grep -Eqi 'TRUENAS-MINI'; then

camcontrol devlist | grep -i "Micron 5300 MTFDDAK480TDS" | cut -d, -f 2 | tr -d \) | grep -v "ses" | xargs -I DRIVE smartctl -x /dev/DRIVE | grep -Ei "Device Model|Serial Number|User Capacity" >> swqc-tmp/$SERIAL-read-write-cache.txt
#
#
fi
#
#
if echo "$PRODUCT" | grep -Eqi 'TRUENAS-MINI' && cat swqc-tmp/$SERIAL-read-write-cache.txt | grep -oh "\w*16.0 GB\w*"| grep -Fwqi -e "16.0 GB"; then
echo "Write Cache Correctly OP to 16.0 GB"  >> swqc-tmp/$SERIAL-part-count.txt
echo "Write Cache Correctly OP to 16.0 GB" >> swqc-tmp/$SERIAL-diffme.txt
echo "Write Cache OP" >> swqc-tmp/$SERIAL-PorF.txt
echo "pass" >> swqc-tmp/$SERIAL-PorF.txt
#
elif echo "$PRODUCT" | grep -Eqi 'TRUENAS-MINI' && cat swqc-tmp/$SERIAL-read-write-cache.txt | grep -oh "\w*480 GB\w*"| grep -Fwqi -e "480 GB"; then
echo "Write cache incorrectly left at 480 GB" >> swqc-tmp/$SERIAL-part-count.txt
echo "Write cache incorrectly left at 480 GB" >> swqc-tmp/$SERIAL-diffme.txt
echo "Write Cache OP" >> swqc-tmp/$SERIAL-PorF.txt
echo "fail" >> swqc-tmp/$SERIAL-PorF.txt
#
#
fi
#
echo "Collecting Drive Temp " >> swqc-tmp/swqc-output.txt 
#
#
#
#
camcontrol devlist | cut -d, -f2 | tr -d \) | grep -v ses | xargs -I DRIVE smartctl -A /dev/DRIVE | grep -i temperature | grep -i current >> swqc-tmp/swqc-output.txt
camcontrol devlist | cut -d, -f2 | tr -d \) | grep -v ses | xargs -I DRIVE smartctl -A /dev/DRIVE | grep -i temperature | grep -i current > swqc-tmp/drivetemp-output.txt
#
#
DRIVETEMP=$(cat swqc-tmp/drivetemp-output.txt)
#
#
echo "===============================" >> swqc-tmp/swqc-output.txt
#
#
echo echo "Collecting Drive Stat and Drive Temp " >> swqc-tmp/swqc-output.txt
#
#
camcontrol devlist | cut -d, -f2 | tr -d \) | grep -v ses | xargs -I DRIVE smartctl -A /dev/DRIVE |grep -Ei 'vendor:|Product:|Revision:|Number:|Status:|Current:|grown defect list:' >> swqc-tmp/swqc-output.txt
camcontrol devlist | cut -d, -f2 | tr -d \) | grep -v ses | xargs -I DRIVE smartctl -A /dev/DRIVE | grep -Ei 'vendor:|Product:|Revision:|Number:|Status:|Current:|grown defect list:' > swqc-tmp/drivestat-tmp.txt
#
#
#
STATNTMP=$(cat swqc-tmp/drivestat-tmp.txt)
#
#
#
echo "zpool status" >> swqc-tmp/$SERIAL-part-count.txt
zpool status | >> swqc-tmp/$SERIAL-part-count.txt
#
#
echo "zpool list" >> swqc-tmp/$SERIAL-part-count.txt
zpool list >> swqc-tmp/$SERIAL-part-count.txt
#
#
echo "point check A" >> swqc-tmp/swqc-output.txt
echo "point check A" > swqc-tmp/pointcheck-A.txt
#
echo "===============================" >> swqc-tmp/swqc-output.txt
#
#
if echo "$PRODUCT" | grep -oh "\w*R50\w*"| grep -Fwqi -e R50 ; then
#
#
echo "Current Drive Temps" >> swqc-tmp/swqc-output.txt
#
echo "Drive Check to ensure everthing is below 60C:"  >> swqc-tmp/swqc-output.txt
#
camcontrol devlist | cut -d, -f2 | tr -d \) | grep -v ses | xargs -I DRIVE smartctl -A /dev/DRIVE | grep -i temperature | grep -i current >> swqc-tmp/ swqc-output.txt
camcontrol devlist | cut -d, -f2 | tr -d \) | grep -v ses | xargs -I DRIVE smartctl -A /dev/DRIVE | grep -i temperature | grep -i current > swqc-tmp/R50drivetemp-output.txt
echo "Current Drive Temp" >> swqc-tmp/$SERIAL-part-count.txt
echo "Drive Check to ensure everthing is below 60C:" >> swqc-tmp/$SERIAL-part-count.txt
camcontrol devlist | cut -d, -f2 | tr -d \) | grep -v ses | xargs -I DRIVE smartctl -A /dev/DRIVE | grep -i temperature | grep -i current >> swqc-tmp/$SERIAL-part-count.txt
#
#
R50DRIVETEMP=$(cat swqc-tmp/R50drivetemp-output.txt)
#
#
#
echo " Verifying Fan speed is set to FULL for R50 " > swqc-tmp/swqc-output.txt
#
# Run the following command to make sure fan speed is set to Full:
# It should return 01
# The values are:
# Standard: 0
# Full: 1
# Optimal: 2
# Heavy IO: 4
#
ipmitool raw 0x30 0x45 0x00 >> swqc-tmp/swqc-output.txt
ipmitool raw 0x30 0x45 0x00 > swqc-tmp/swqc-r50fanspeed.txt
#
R50FANSPEED=$(cat swqc-tmp/swqc-r50fanspeed.txt)
#
#
fi
#
#
#
if echo "$PRODUCT"|grep -Fwqi -e TRUENAS-R50B ; then
#
#
echo "TRUENAS-R50B Specific SWQC Checks " >> swqc-tmp/swqc-output.txt
#
#
echo "TRUENAS-R50B Specific SWQC Checks" >> swqc-tmp/$SERIAL-part-count.txt
#
#
fi
#
#
if echo "$PRODUCT"|grep -Fwqi -e TRUENAS-R50B ; then
#
#
echo system is an "TRUENAS-R50B"
#
#
#
echo "TrueNAS TRUENAS-R50B fan info" >> swqc-tmp/swqc-output.txt
echo "TrueNAS TRUENAS-R50B fan info" >> swqc-tmp/$SERIAL-part-count.txt
echo "FANS 234 are installed left to rightto main chassis. FANA is connected to Left internal FAN while FANB is connected to Right Internal FAN " >> swqc-tmp/$SERIAL-part-count.txt
echo "FANS 234 are installed left to rightto main chassis. FANA is connected to Left internal FAN while FANB is connected to Right Internal FAN " >> swqc-tmp/swqc-output.txt
ipmitool sensor list | grep -i 'FAN[1234AB]' >> swqc-tmp/swqc-output.txt
ipmitool sensor list | grep -i 'FAN[1234AB]' >  swqc-tmp/R50Bfan-output.txt
ipmitool sensor list | grep -i 'FAN[1234AB]' >> swqc-tmp/$SERIAL-part-count.txt
#
R50BFAN=$( cat swqc-tmp/R50Bfan-output.txt)
#
#
#
fi
#
#
if echo "$PRODUCT"|grep -Fwqi -e TRUENAS-R50B ; then
#
echo " Verifying Fan speed is set to FULL for R50 " > swqc-tmp/swqc-output.txt
ipmitool sensor list | grep -i 'FAN[1234AB]'>> swqc-tmp/$SERIAL-part-count.txt
#
# Run the following command to make sure fan speed is set to Full:
# It should return 01
# The values are:
# Standard: 00
# Full: 01
# Optimal: 02
# Heavy IO: 04
#
ipmitool raw 0x30 0x45 0x00 >> swqc-tmp/swqc-output.txt
ipmitool raw 0x30 0x45 0x00 > swqc-tmp/swqc-r50Bfanspeed.txt
ipmitool raw 0x30 0x45 0x00 >> swqc-tmp/$SERIAL-part-count.txt
#
R50BFANSPEED=$(cat swqc-tmp/swqc-r50Bfanspeed.txt)
#
#
fi
#
# pg 64 TrueNAS R-Series R50B Redbook
#
# The default will be “Optimal speed”: change this to “Full Speed” 
#
#
if echo "$PRODUCT"|grep -Fwqi -e TRUENAS-R50B  && echo "$R50BFANSPEED" | grep -oh "\w*01\w*"| grep -Fwqi -e 01; then
#
echo "Fan speed for TrueNAS-R50B is correctly showing as $R50BFANSPEED"  >> swqc-tmp/swqc-output.txt
echo "Fan speed for TrueNAS-R50B is correctly showing as $R50BFANSPEED" > swqc-tmp/R50BFANSPEED.txt
echo "Fan speed for TrueNAS-R50B is correctly showing as $R50BFANSPEED" >> swqc-tmp/$SERIAL-part-count.txt
echo "Fan Speed" >> swqc-tmp/$SERIAL-diffme.txt
echo "Fan speed for TrueNAS-R50B is correctly showing as $R50BFANSPEED" >> swqc-tmp/$SERIAL-diffme.txt
echo "Fan speed" >> swqc-tmp/$SERIAL-PorF.txt
echo "pass" >> swqc-tmp/$SERIAL-PorF.txt
#
elif echo "$PRODUCT"| grep -Fwqi -e TRUENAS-R50B && echo "$BIOVER" | grep -oh "\w*01\w*" != 01; then
#
echo "TRUENAS-R50B Fan speed is showing as $R50BFANSPEED it should be set to FULL which is 01" >> swqc-tmp/swqc-output.txt
echo "TRUENAS-R50B Fan speed is showing as $R50BFANSPEED it should be set to FULL which is 01" > swqc-tmp/R50BFANSPEED.txt
echo "TRUENAS-R50B Fan speed is showing as $R50BFANSPEED it should be set to FULL which is 01" >> swqc-tmp/warning.txt
echo "TRUENAS-R50B Fan speed is showing as $R50BFANSPEED it should be set to FULL which is 01" >> swqc-tmp/$SERIAL-part-count.txt
echo "Fan Speed" >> swqc-tmp/$SERIAL-diffme.txt
echo "TRUENAS-R50B Fan speed is showing as $R50BFANSPEED it should be set to FULL which is 01" >> swqc-tmp/$SERIAL-diffme.txt
echo "Fan speed" >> swqc-tmp/$SERIAL-PorF.txt
echo "fail" >> swqc-tmp/$SERIAL-PorF.txt
#
#
R50BFANSP=$(cat > swqc-tmp/R50BFANSPEED.txt)
#
#
#
fi
#
#
#
#
#
if echo "$PRODUCT"|grep -Fwqi -e TRUENAS-R50B ; then
#
echo "TRUENAS-R50B Fan Info "  >> swqc-tmp/swqc-output.txt
echo "FANS 234 are installed left to rightto main chassis. FANA is connected to Left internal FAN while FANB is connected to Right Internal FAN " >> swqc-tmp/$SERIAL-part-count.txt
echo "FANS 234 are installed left to rightto main chassis. FANA is connected to Left internal FAN while FANB is connected to Right Internal FAN " >> swqc-tmp/swqc-output.txt
ipmitool sensor list | grep -i 'FAN[1234AB]' >> swqc-tmp/swqc-output.txt
ipmitool sensor list | grep -i 'FAN[1234AB]' >  swqc-tmp/R50Bfan-output.txt
ipmitool sensor list | grep -i 'FAN[1234AB]' >> swqc-tmp/$SERIAL-part-count.txt
echo "Fan Info" >> swqc-tmp/$SERIAL-diffme.txt
ipmitool sensor list | grep -i 'FAN[1234AB]'>> swqc-tmp/$SERIAL-diffme.txt
#
R50BFAN=$( cat swqc-tmp/R50Bfan-output.txt)
#
#
#
ipmitool sdr list | grep -i 'FAN[1234AB]' > swqc-tmp/R50B-sdrout.txt
ipmitool sdr list | grep -i 'FAN[1234AB]' >> swqc-tmp/swqc-output.txt
ipmitool sdr list | grep -i 'FAN[1234AB]' >> swqc-tmp/$SERIAL-part-count.txt
ipmitool sdr list | grep -i 'FAN[1234AB]' >> swqc-tmp/$SERIAL-diffme.txt
#
#
#
R50BSDR=$( cat swqc-tmp/R50B-sdrout.txt)
#
fi
#
if echo "$R50BSDR"|grep -Fwqi  -e "no reading" ; then 
#
#
echo "The following FAN(s) show no reading" > swqc-tmp/R50B-fan-errors.txt
echo "The following FAN(s) show no reading" >> swqc-tmp/swqc-output.txt
echo "The following FAN(s) show no reading" >> swqc-tmp/$SERIAL-part-count.txt
cat swqc-tmp/R50B-sdrout.txt | grep -i "no reading" >> swqc-tmp/swqc-output.txt
cat swqc-tmp/R50B-sdrout.txt | grep -i "no reading" >> swqc-tmp/R50B-fan-errors.txt
cat swqc-tmp/R50B-sdrout.txt | grep -i "no reading" >> swqc-tmp/$SERIAL-part-count.txt
#
R50BFAN-ERRORS=$(cat swqc-tmp/R50B-fan-errors.txt)
#
fi
#
#
#
if echo "$PRODUCT"|grep -Fwqi -e TRUENAS-R50B ; then
#
echo "Checking drives to make sure they are below 60C:" >> swqc-tmp/$SERIAL-part-count.txt
# Check drives to ensure they are below 60C:
echo "Checking drives to make sure they are below 60C:" >> swqc-tmp/swqc-output.txt
#
#
camcontrol devlist | cut -d, -f2 | tr -d \) | grep -v ses | xargs -I DRIVE smartctl -A /dev/DRIVE | grep -i temperature | grep -i current >> swqc-tmp/swqc-output.txt
camcontrol devlist | cut -d, -f2 | tr -d \) | grep -v ses | xargs -I DRIVE smartctl -A /dev/DRIVE | grep -i temperature | grep -i current > swqc-tmp/R50Bdrivetemp.txt
camcontrol devlist | cut -d, -f2 | tr -d \) | grep -v ses | xargs -I DRIVE smartctl -A /dev/DRIVE | grep -i temperature | grep -i current >> swqc-tmp/$SERIAL-part-count.txt
#
R50BDRIVETEMP=$(echo > swqc-tmp/R50Bdrivetemp.txt)
#
#
fi
#
	
#"READ / Write Cache capacity check"	
#	
if echo "$PRODUCT" | grep -Eqi 'TRUENAS-R50B'; then	
#	
touch swqc-tmp/$SERIAL-read-write-cache.txt	
#	
#echo "READ / Write Cache capacity check"  >> swqc-tmp/$SERIAL-part-count.txt	
#echo "READ / Write Cache capacity check" >> swqc-tmp/$SERIAL-diffme.txt	
camcontrol devlist | grep -i micron |cut -d "," -f2 | sed 's/)//g'| grep -v ses | xargs -I DRIVE smartctl -x /dev/DRIVE| grep -Ei "device model: | serial number|user capacity"  >> swqc-tmp/$SERIAL-read-write-cache.txt	
#	
#	
fi	
#	
#	
if echo "$PRODUCT" | grep -Eqi 'TRUENAS-R50B' && cat swqc-tmp/$SERIAL-read-write-cache.txt | grep -oh "\w*16.0 GB\w*"| grep -Fwqi -e "16.0 GB"; then	
echo "Write Cache Correctly OP to 16.0 GB" >> swqc-tmp/$SERIAL-diffme.txt	
echo "Write Cache Correctly OP to 16.0 GB" >> swqc-tmp/$SERIAL-diffme.txt	
#	
#	
fi	
#	
#	
if echo "$PRODUCT" | grep -Eqi 'TRUENAS-R50B' && cat swqc-tmp/$SERIAL-read-write-cache.txt | grep -oh "\w*800 GB\w*"| grep -Fwqi -e "800 GB"; then	
echo "Read Cache 800 GB present" >> swqc-tmp/$SERIAL-diffme.txt	
echo "Read Cache  800 GB Present" >> swqc-tmp/$SERIAL-diffme.txt	
#	
#	
fi	
#	
#	
#	
#
#
if echo "$PRODUCT"|grep -Fwqi -e TRUENAS-R50B  && dmidecode -t memory | grep -oh "\w*36ASF4G72PZ-2G9E2\w*"| grep -Fwqi -e 36ASF4G72PZ-2G9E2; then
dmidecode| grep -i part | grep -i 36ASF4G72PZ-2G9E2 | wc -l > nodea-r50_memory_count.txt
echo "Memory Count" >> swqc-tmp/$SERIAL-diffme.txt
dmidecode| grep -i part | grep -i 36ASF4G72PZ-2G9E2 | wc -l >> swqc-tmp/$SERIAL-diffme.txt
echo "Memory Count" >> swqc-tmp/$SERIAL-part-count.txt
dmidecode -t memory | grep -i 36ASF4G72PZ-2G9E2 | wc -l >> swqc-tmp/$SERIAL-part-count.txt
fi
#
#
if echo "$PRODUCT"|grep -Fwqi -e TRUENAS-R50B  && dmidecode -t memory| grep -oh "\w*M393A2K40BB1-CRC\w*"| grep -Fwqi -e M393A2K40BB1-CRC; then
echo "Checking memory on R50B " >> swqc-tmp/swqc-output.txt
echo "Checking memory count on R50B " >> swqc-tmp/parts-list.txt
echo "Checking memory count on R50B " >> swqc-tmp/$SERIAL-part-count.txt
dmidecode -t memory | grep -i M393A2K40BB1-CRC | wc -l >> swqc-tmp/swqc-output.txt
dmidecode -t memory | grep -i M393A2K40BB1-CRC | wc -l >> swqc-tmp/parts-list.txt
echo "Memory Count" >> swqc-tmp/$SERIAL-part-count.txt
dmidecode -t memory | grep -i M393A2K40BB1-CRC | wc -l >> swqc-tmp/$SERIAL-part-count.txt
#
#
fi
#
#
echo "Checking R50B has correct PWS and it it is the correct revision:" >> swqc-tmp/$SERIAL-part-count.txt
# Checking R50B has correct PWS and it it is the correct revision:
echo "Checking R50B has correct PWS and it it is the correct revision:" >> swqc-tmp/swqc-output.txt
#
#
# Each R50B should come Preinstalled with 2 x 3Y 1300W Power supply modules. 
# Ensure that the power supply’s part number matches that of the current Revision, (YSEF1300EM / A05.)
# 
#
if echo "$PRODUCT"|grep -Fwqi -e TRUENAS-R50B ; then
dmidecode -t39 | grep -Ei "Model Part Number|Revision:" | tr "\n\t" " " | sed 's/ Model Part Number: /\;/g;s/  Revision: /,/g' | tr ";" "\n" | grep -Eiv '(O.E.M.|^$)' >> swqc-tmp/swqc-output.txt
dmidecode -t39 | grep -Ei "Model Part Number|Revision:" | tr "\n\t" " " | sed 's/ Model Part Number: /\;/g;s/  Revision: /,/g' | tr ";" "\n" | grep -Eiv '(O.E.M.|^$)' >> swqc-tmp/R50B-PWS-OUTPUT.txt
dmidecode -t39 | grep -Ei "Model Part Number|Revision:" | tr "\n\t" " " | sed 's/ Model Part Number: /\;/g;s/  Revision: /,/g' | tr ";" "\n" | grep -Eiv '(O.E.M.|^$)' >> swqc-tmp/$SERIAL-part-count.txt
#
#
R50BPWS=$(cat swqc-tmp/R50B-PWS-OUTPUT.txt)
#
#
fi
#
#
if echo "$PRODUCT"|grep -Fwqi -e TRUENAS-R50B  && echo "$BIOVER" | grep -oh "\w*3.3.V6\w*"| grep -Fwqi -e 3.3.V6; then
#
echo "Bios version for TRUENAS-R50B is correctly showing as 3.3.V6"  >> swqc-tmp/swqc-output.txt
echo "Bios version for TRUENAS-R50B is correctly showing as 3.3.V6"  > swqc-tmp/R50Bbios.txt
echo "Bios version" >> swqc-tmp/$SERIAL-diffme.txt
echo "Correctly showing as 3.3.V6" >> swqc-tmp/$SERIAL-part-count.txt
echo "Correctly showing as 3.3.V6" >> swqc-tmp/$SERIAL-diffme.txt
echo "Bios version" >> swqc-tmp/$SERIAL-PorF.txt
echo "pass" >> swqc-tmp/$SERIAL-PorF.txt
#
elif echo "$PRODUCT"| grep -Fwqi -e TRUENAS-R50B && echo "$BIOVER" | grep -oh "\w*3.3.V6\w*" != 3.3.V6; then
#
echo "Bios version for TRUENAS-R50B is showing as $BIOVER it should be  3.3.V6" >> swqc-tmp/swqc-output.txt
echo "Bios version for TRUENAS-R50B is showing as $BIOVER it should be  3.3.V6" > swqc-tmp/R50Bbios.txt
echo "Bios version for TRUENAS-R50B is showing as $BIOVER it should be  3.3.V6" >> swqc-tmp/warning.txt
echo "Bios version is showing as $BIOVER it should be 3.3.V6" >> swqc-tmp/$SERIAL-part-count.txt
echo "Bios version" >> swqc-tmp/$SERIAL-diffme.txt
echo "Bios version is showing as $BIOVER it should be 3.3.V6" >> swqc-tmp/$SERIAL-diffme.txt
echo "Bios version" >> swqc-tmp/$SERIAL-PorF.txt
echo "fail" >> swqc-tmp/$SERIAL-PorF.txt
#
#
R50BBIOV=$(cat swqc-tmp/R50Bbios.txt)
#
#
fi
#
#
echo "BMC Firmware"  >> swqc-tmp/swqc-output.txt
#
#
# BMC Firmware for TRUENAS-R50B should be1.71.11
#
#
echo "point check B" >> swqc-tmp/swqc-output.txt
echo "point check B" > swqc-tmp/pointcheck-B.txt
#
#
if echo "$PRODUCT"|grep -Fwqi -e TRUENAS-R50B  && echo "$BMCINFO" | grep -oh "\w*1.71\w*"| grep -Fwqi -e 1.71; then
echo "BMC firmware for TRUENAS-R50B is correctly showing as $BMCINFO it should be  1.71" >> swqc-tmp/swqc-output.txt
echo "BMC firmware for TRUENAS-R50B is correctly showing as $BMCINFO it should be  1.71" > swqc-tmp/R50-bmc.txt
echo "Correctly showing as $BMCINFO it should be  1.71" >> swqc-tmp/$SERIAL-part-count.txt
echo "BMC firmware" >> swqc-tmp/$SERIAL-diffme.txt
echo "Correctly showing as $BMCINFO it should be  1.71" >> swqc-tmp/$SERIAL-diffme.txt
echo "BMC firmware" >> swqc-tmp/$SERIAL-PorF.txt
echo "pass" >> swqc-tmp/$SERIAL-PorF.txt
#
#
elif echo "$PRODUCT"| grep -Fwqi -e TRUENAS-R50B && echo "$BMCINFO" | grep -oh "\w*1.71\w*" != 1.71; then
#
echo "BMC firmware for TRUENAS-R50B is showing as $BMCINFO it should be 1.71" >> swqc-tmp/swqc-output.txt
echo "BMC firmware for TRUENAS-R50B is showing as $BMCINFO it should be  1.71" > swqc-tmp/R50-bmc.txt
echo "BMC firmware for TRUENAS-R50B is showing as $BMCINFO it should be  1.71" >> swqc-tmp/warning.txt
echo "Bios version for TRUENAS-R50B is showing as $BMCINFO it should be  1.71" >> swqc-tmp/$SERIAL-part-count.txt
echo "BMC firmware" >> swqc-tmp/$SERIAL-diffme.txt
echo "BMC firmware is showing as $BMCINFO it should be  1.71" >> swqc-tmp/$SERIAL-diffme.txt
echo "BMC firmware" >> swqc-tmp/$SERIAL-PorF.txt
echo "fail" >> swqc-tmp/$SERIAL-PorF.txt
#
#
R50BMC=$(cat swqc-tmp/R50-bmc.txt)
#
fi
#
#
#
#
#
if echo "$PRODUCT"|grep -Fwqi -e TRUENAS-R50B  && pciconf -lvcb | grep -oh "\w*X722\w*"| grep -Fwqi -e X722; then
echo "On Board Nic Count" >> swqc-tmp/swqc-output.txt
echo "On Board Nic Count" >> swqc-tmp/$SERIAL-diffme.txt
echo "On Board Nic Count" >> swqc-tmp/$SERIAL-part-count.txt
#
pciconf -lvcb | grep -i X722 | wc -l > swqc-tmp/R50B-onboard-nic-count.txt
pciconf -lvcb | grep -i X722 | wc -l  >> swqc-tmp/$SERIAL-part-count.txt
pciconf -lvcb | grep -i X722 | wc -l  >> swqc-tmp/$SERIAL-diffme.txt
pciconf -lvcb | grep -i X722 | wc -l  >> swqc-tmp/swqc-output.txt
#
#
fi
#
#
#
#
#
if echo "$PRODUCT"|grep -Fwqi -e TRUENAS-R50B  && pciconf -lvcb | grep -oh "\w*T62100-LP-CR\w*"| grep -Fwqi -e T62100-LP-CR; then
echo "Add on nic card" >> swqc-tmp/swqc-output.txt
echo "Add on nic card" >> swqc-tmp/$SERIAL-diffme.txt
echo "Add on nic card" >> swqc-tmp/$SERIAL-part-count.txt
#
pciconf -lvcb | grep -i T62100-LP-CR | wc -l > swqc-tmp/R50B-add-on-nic-count.txt
pciconf -lvcb | grep -i T62100-LP-CR > swqc-tmp/R50B-add-on-nic-list.txt
pciconf -lvcb | grep -i T62100-LP-CR | wc -l  >> swqc-tmp/$SERIAL-part-count.txt
pciconf -lvcb | grep -i T62100-LP-CR| wc -l  >> swqc-tmp/$SERIAL-diffme.txt
pciconf -lvcb | grep -i T62100-LP-CR| wc -l >> swqc-tmp/swqc-output.txt
#
#
fi
#
#
#
#
#
if echo "$PRODUCT"|grep -Fwqi -e TRUENAS-R50B  && pciconf -lvcb | grep -oh "\w*T520\w*"| grep -Fwqi -e T520; then
echo "Add on nic card" >> swqc-tmp/swqc-output.txt
echo "Add on nic card" >> swqc-tmp/$SERIAL-diffme.txt
echo "Add on nic card" >> swqc-tmp/$SERIAL-part-count.txt
#
pciconf -lvcb | grep -i T520 | wc -l > swqc-tmp/R50B-add-on-nic-count.txt
pciconf -lvcb | grep -i T520 > swqc-tmp/R50B-add-on-nic-list.txt
pciconf -lvcb | grep -i T520 | wc -l  >> swqc-tmp/$SERIAL-part-count.txt
pciconf -lvcb | grep -i T520 | wc -l  >> swqc-tmp/$SERIAL-diffme.txt
pciconf -lvcb | grep -i T520 | wc -l >> swqc-tmp/swqc-output.txt
#
#
fi
#
#
#
#
#
#
if echo "$PRODUCT"|grep -Fwqi -e TRUENAS-R50B  && ifconfig -va | grep -oh "\w*QSFP-SR4-40G\w*"| grep -Fwqi -e QSFP-SR4-40G; then
echo "40G SFP Count" >> swqc-tmp/swqc-output.txt
echo "40G SFP Count" >> swqc-tmp/$SERIAL-diffme.txt
echo "40G SFP Count" >> swqc-tmp/$SERIAL-part-count.txt
#
ifconfig -va | grep -i QSFP-SR4-40G | wc -l > swqc-tmp/R50B-40G-SFP-count.txt
ifconfig -va | grep -i QSFP-SR4-40G > swqc-tmp/R50B-40G-SFP-list.txt
ifconfig -va | grep -i QSFP-SR4-40G | wc -l  >> swqc-tmp/$SERIAL-part-count.txt
ifconfig -va | grep -i QSFP-SR4-40G | wc -l >> swqc-tmp/$SERIAL-diffme.txt
ifconfig -va | grep -i QSFP-SR4-40G | wc -l >> swqc-tmp/swqc-output.txt
#
#
fi
#
#
#
#
echo "point check C" >> swqc-tmp/swqc-output.txt
echo "point check C" > swqc-tmp/pointcheck-C.txt
#
#
#
echo "===============================" >> swqc-tmp/swqc-output.txt
#Software Validation of M.2 Boot Device
echo "Software Validation of M.2 Boot Device" >> swqc-tmp/swqc-output.txt
echo "Software Validation of M.2 Boot Device" >> swqc-tmp/$SERIAL-part-count.txt
#
#
#
nvmecontrol devlist | grep nvme0 >> swqc-tmp/swqc-output.txt
nvmecontrol devlist | grep nvme0 > swqc-tmp/nvmecontrol-output.txt
nvmecontrol devlist | grep nvme0 >> swqc-tmp/$SERIAL-part-count.txt
#
NVME=$( cat swqc-tmp/nvmecontrol-output.txt)
#
#
#
echo "===============================" >> swqc-tmp/swqc-output.txt
#
#
# 
echo "SRIS disablement" >> swqc-tmp/swqc-output.txt
echo "SRIS disablement" >> swqc-tmp/$SERIAL-diffme.txt
echo "SRIS disablement" >> swqc-tmp/$SERIAL-PorF.txt
# 
# 
# check of SRIS disablement  SRIS on CM6 drives NVMe U.2 cache drives
# Performance SSD Slog/L2ARC
# BiCS FLASH TLC
# The M-Series requires SRIS(Seperate Reference) clock to be disabled on drives else they may not attach on boot to second controller or more rarely either controller. 2 # or more drives in an M-series without SRIS disabled on all of them makes issue more likely to happen.
# 
nvmecontrol logpage -p 0xF1 -b nvme3 | python3 -c 'import sys;offset = 101 ; value = sys.stdin.buffer.read(offset + 1); print(value[-1] & 1)' > swqc-tmp/SRIS-disablement.txt
#
#
SRISDISABLEMENT=$(cat swqc-tmp/SRIS-disablement.txt)
#
#
#
#
echo "===============================" >> swqc-tmp/swqc-output.txt
#
#
#
# Identification of SATA ports the hard drives are connected to 
# With TrueNAS 12 we can use the following command to verify that the drives are connected to the correct controllers
#
# 
sesutil show >> swqc-tmp/swqc-output.txt
sesutil show > swqc-tmp/sesutilshow-output.txt
sesutil show >> swqc-tmp/$SERIAL-part-count.txt
#
#
SESUTILSHOW=$( cat swqc-tmp/sesutilshow-output.txt)
# 
#
# verify drives are connected to the correct controller 
#
#
sesutil map >> swqc-tmp/swqc-output.txt
sesutil map > swqc-tmp/sesutilmap-output.txt
sesutil map >> swqc-tmp/$SERIAL-part-count.txt
#
SESUTILMAP=$(cat swqc-tmp/sesutilmap-output.txt)
#
#
dmesg | grep -i ses >> swqc-tmp/swqc-output.txt
dmesg | grep -i ses > swqc-tmp/dmesgout-output.txt
dmesg | grep -i ses >> swqc-tmp/$SERIAL-part-count.txt
#
DMESGOUT=$( cat swqc-tmp/dmesgout-output.txt)
#
#
echo "===============================" >> swqc-tmp/swqc-output.txt
#
#
echo "Zpool Information" >> swqc-tmp/swqc-output.txt
#
#
# Collect Zpool information
#
#
#
zpool status >> swqc-tmp/swqc-output.txt
zpool status > swqc-tmp/zpinfo-output.txt
zpool status >> swqc-tmp/$SERIAL-part-count.txt
#
#
ZPINFO=$( cat swqc-tmp/zpinfo-output.txt)
#
#
#
#
#
echo "===============================" >> swqc-tmp/swqc-output.txt
#
#Firmware Validation Procedure of NVDIMM for all systems running 12 or later
#
echo "Firmware Validation Procedure of NVDIMM for all systems running 12 or later" >> swqc-tmp/swqc-output.txt
echo Firmware Validation Procedure of NVDIMM for all systems running 12 or later
#
#
#
# Check that the selected firmware slot is selected and running
#
#
ixnvdimm /dev/nvdimm0 >> swqc-tmp/swqc-output.txt
ixnvdimm /dev/nvdimm0 > swqc-tmp/nvdimmslot-output.txt
ixnvdimm /dev/nvdimm1 >> swqc-tmp/swqc-output.txt
ixnvdimm /dev/nvdimm1 >> swqc-tmp/nvdimmslot-output.txt
ixnvdimm /dev/nvdimm1 >> swqc-tmp/$SERIAL-part-count.txt
#
#
NVDIMSLOT=$( cat swqc-tmp/nvdimmslot-output.txt)
#
# Verify Version
#
ixnvdimm /dev/nvdimm0 |grep -o "slot1: [0-9A-F][0-9A-F]" >> swqc-tmp/swqc-output.txt
ixnvdimm /dev/nvdimm0 |grep -o "slot1: [0-9A-F][0-9A-F]" > swqc-tmp/nvdimmversion-output.txt
ixnvdimm /dev/nvdimm1 |grep -o "slot1: [0-9A-F][0-9A-F]" >> swqc-tmp/swqc-output.txt
ixnvdimm /dev/nvdimm1 |grep -o "slot1: [0-9A-F][0-9A-F]" >> swqc-tmp/nvdimmversion-output.txt
ixnvdimm /dev/nvdimm1 |grep -o "slot1: [0-9A-F][0-9A-F]" >> swqc-tmp/$SERIAL-part-count.txt
#
#
#
NVDIMMVERSION=$( cat swqc-tmp/nvdimmversion-output.txt)
#
# The returned 2 digits at end of text will be version with out a dot for example 22 is 2.2 and 24 is 2.4
# 16 GB nvdimm have firmware 2.2 and 32 have firmware 2.4
# Match version against qualified firmware for nvdimm in 1st table in
# Nvdimm Firmware Update
#
#
#
echo "===============================" >> swqc-tmp/swqc-output.txt
echo "===============================" >> swqc-tmp/$SERIAL-part-count.txt
echo "===============================" >> swqc-tmp/$SERIAL-part-count.txt
#
#
echo "Fan and Sensor Information" >> swqc-tmp/swqc-output.txt
#
echo "Checking for Presence of FANA and thresholds for FANA, FANA1, and FAN2"
#
# Check sensor thresh holds should be lower 200 300 500
# X+ only needs FANA checked
# XL+ needs FANA FAN1 and FAN2 checked
#
#
ipmitool sensor get FANA | grep -i lower > swqc-tmp/fana-check-output.txt
#
#
FANACHECK=$( cat swqc-tmp/fana-check-output.txt)
#
#
if echo "$FANACHECK" | grep -Fwqi  -e lower ; then 

ipmitool sensor list | grep -Ei 'FAN[A12]' >> swqc-tmp/swqc-output.txt
ipmitool sensor list | grep -Ei 'FAN[A12]' > swqc-tmp/fana12-thresh-output.txt
#
FANTHRESH=$( cat swqc-tmp/fana12-thresh-output.txt)
#
echo "$FANTHRESH"
# 
else 
#
echo "FANA is not present in this system"
echo "FANA is not present in this system" >> swqc-tmp/swqc-output.txt
#
fi
#
#
echo "===============================" >> swqc-tmp/swqc-output.txt
#
#
#
echo "point check D" >> swqc-tmp/swqc-output.txt
echo "point check D" > swqc-tmp/pointcheck-D.txt
#
####################################################################
#Bios for TRUENAS-M60 should be 3.3.V6
#
#
#
#
#
if echo "$PRODUCT"| grep -Fwqi -e "Product Name: TRUENAS-M60-S" && echo "$BIOVER" | grep -oh "\w*3.3aV3\w*"| grep -Fwqi -e 3.3aV3; then
#
#
echo "Checking TRUENAS-M60 bios version it should be 3.3aV3"
#
#
echo "Bios verson" >> swqc-tmp/$SERIAL-diffme.txt
echo "Bios version">> swqc-tmp/$SERIAL-part-count.txt
#
echo "Correctly showing as  3.3aV3"  >> swqc-tmp/swqc-output.txt
echo "Correctly showing as  3.3aV3"  > swqc-tmp/M60-bios.txt
echo "Correctly showing as  3.3aV3" >> swqc-tmp/$SERIAL-diffme.txt
echo "Correctly showing as  3.3aV3" >> $SERIAL-part-count.txt
echo "Bios verson" >> swqc-tmp/$SERIAL-PorF.txt
echo "pass" >> swqc-tmp/$SERIAL-PorF.txt
#
#
elif echo "$PRODUCT"| grep -Fwqi -e 'Product Name: TRUENAS-M60-S' && echo "$BIOVER" | grep -oh "\w*3.3.V6\w*" != 3.3.V6; then
#
#
#
echo "Bios verson" >> swqc-tmp/$SERIAL-diffme.txt
echo "Bios version" >> swqc-tmp/$SERIAL-part-count.txt
#
echo "Bios version for TRUENAS-M60 is showing as $BIOVER it should be  3.3aV3" >> swqc-tmp/swqc-output.txt
echo "Bios version for TRUENAS-M60 is showing as $BIOVER it should be  3.3aV3" > swqc-tmp/M60-bios.txt
echo "Bios version for TRUENAS-M60 is showing as $BIOVER it should be  3.3aV3" >> swqc-tmp/warning.txt
echo "Showing as $BIOVER it should be  3.3aV3" >> swqc-tmp/$SERIAL-diffme.txt
echo "Bios version for TRUENAS-M60 is showing as $BIOVER it should be  3.3aV3" >> swqc-tmp/$SERIAL-part-count.txt
echo "Bios verson" >> swqc-tmp/$SERIAL-PorF.txt
echo "fail" >> swqc-tmp/$SERIAL-PorF.txt
#
#
M60BIOV=$(cat swqc-tmp/M60-bios.txt)
#
#
fi

#
#
if echo "$PRODUCT"| grep -Fwqi -e "Product Name: TRUENAS-M60-S" && echo "$BMCINFO" | grep -oh "\w*6.73\w*"| grep -Fwqi -e 6.73; then
#
#
#
echo "BMC Firmware" >> swqc-tmp/$SERIAL-diffme.txt
echo "Bios Firmware" >> swqc-tmp/$SERIAL-part-count.txt
#
#
echo "BMC Firmware for TRUENAS-M60 should be 6.73"  >> swqc-tmp/swqc-output.txt
# 
#
echo "BMC firmware for TRUENAS-M60 is correctly showing as $BMCINFO it should be  6.73" >> swqc-tmp/swqc-output.txt
echo "BMC firmware for TRUENAS-M60 is correctly showing as $BMCINFO it should be  6.73" > swqc-tmp/M60-bmc.txt
echo "BMC firmware for TRUENAS-M60 is correctly showing as $BMCINFO it should be  6.73" >> swqc-tmp/$SERIAL-diffme.txt
echo "BMC firmware" >> swqc-tmp/$SERIAL-PorF.txt
echo "pass" >> swqc-tmp/$SERIAL-PorF.txt
#
elif echo "$PRODUCT"| grep -Fwqi -e "Product Name: TRUENAS-M60-S" && echo "$BMCINFO" | grep -oh "\w*6.73\w*" != 6.73; then
#
echo "BMC firmware for TRUENAS-M60 is showing as $BMCINFO it should be  6.73" >> swqc-tmp/swqc-output.txt
echo "BMC firmware for TRUENAS-M60 is showing as $BMCINFO it should be  6.73" > swqc-tmp/M60-bmc.txt
echo "BMC firmware for TRUENAS-M60 is showing as $BMCINFO it should be  6.73" >> swqc-tmp/warning.txt
echo "BMC firmware showing as $BMCINFO it should be  6.73">> swqc-tmp/$SERIAL-diffme.txt
echo "BMC firmware" >> swqc-tmp/$SERIAL-PorF.txt
echo "fail" >> swqc-tmp/$SERIAL-PorF.txt
#
#
M60BMC=$(cat swqc-tmp/M60-bmc.txt)
#
#
fi
#
#
#
#
if echo "$PRODUCT"| grep -Fwqi -e "Product Name: TRUENAS-M60-S" && pciconf -lvcb | grep -oh "\w*T6225-SO-CR\w*"| grep -Fwqi -e T6225-SO-CR; then
echo "Add on nic card" >> swqc-tmp/swqc-output.txt
echo "Add on nic card" >> swqc-tmp/$SERIAL-diffme.txt
echo "Add on nic card" >> swqc-tmp/$SERIAL-part-count.txt
#
pciconf -lvcb | grep -i T6225-SO-CR | wc -l > swqc-tmp/M60-add-on-nic-count.txt
pciconf -lvcb | grep -i T6225-SO-CR | wc -l  >> swqc-tmp/$SERIAL-part-count.txt
pciconf -lvcb | grep -i T6225-SO-CR | wc -l  >> swqc-tmp/M60-25GB-nic-list-part.txt
pciconf -lvcb | grep -i T6225-SO-CR | wc -l  >> swqc-tmp/$SERIAL-diffme.txt
pciconf -lvcb | grep -i T6225-SO-CR | wc -l >> swqc-tmp/swqc-output.txt
#
#
fi
#
#
#
if echo "$PRODUCT"| grep -Fwqi -e "Product Name: TRUENAS-M60-S" && pciconf -lvcb | grep -oh "\w*T62100-LP-CR\w*"| grep -Fwqi -e T62100-LP-CR; then
echo "Add on nic card" >> swqc-tmp/swqc-output.txt
echo "Add on nic card" >> swqc-tmp/$SERIAL-diffme.txt
echo "Add on nic card" >> swqc-tmp/$SERIAL-part-count.txt
#
pciconf -lvcb | grep -i T62100-LP-CR | wc -l > swqc-tmp/M60-add-on-nic-count.txt
pciconf -lvcb | grep -i T62100-LP-CR | wc -l  >> swqc-tmp/$SERIAL-part-count.txt
pciconf -lvcb | grep -i T62100-LP-CR| wc -l  >> swqc-tmp/$SERIAL-diffme.txt
pciconf -lvcb | grep -i T62100-LP-CR| wc -l >> swqc-tmp/swqc-output.txt
#
#
fi
#
#
#
#
#
if echo "$PRODUCT"| grep -Fwqi -e "Product Name: TRUENAS-M60-S" && ifconfig -va | grep -oh "\w*SM10G-SR\w*"| grep -Fwqi -e SM10G-SR; then
echo "10G SFP Count" >> swqc-tmp/swqc-output.txt
echo "10G SFP Count" >> swqc-tmp/$SERIAL-diffme.txt
echo "10G SFP Count" >> swqc-tmp/$SERIAL-part-count.txt
#
ifconfig -va | grep -i SM10G-SR| wc -l > swqc-tmp/M60-10G-SFP-count.txt
ifconfig -va | grep -i SM10G-SR > swqc-tmp/M60-10G-SFP-list.txt
ifconfig -va | grep -i SM10G-SR | wc -l  >> swqc-tmp/$SERIAL-part-count.txt
ifconfig -va | grep -i SM10G-SR | wc -l >> swqc-tmp/$SERIAL-diffme.txt
ifconfig -va | grep -i SM10G-SR | wc -l >> swqc-tmp/swqc-output.txt
#
#
fi
#
#
#
if echo "$PRODUCT"| grep -Fwqi -e "Product Name: TRUENAS-M60-S" && ifconfig -va | grep -oh "\w*25GBASE-SR\w*"| grep -Fwqi -e 25GBASE-SR; then
echo "25G SFP Count" >> swqc-tmp/swqc-output.txt
echo "25G SFP Count" >> swqc-tmp/$SERIAL-diffme.txt
echo "25G SFP Count" >> swqc-tmp/$SERIAL-part-count.txt
#
ifconfig -va | grep -i 25GBASE-SR| wc -l > swqc-tmp/M60-25G-SFP-count.txt
ifconfig -va | grep -i 25GBASE-SR > swqc-tmp/M60-25G-SFP-list.txt
ifconfig -va | grep -i 25GBASE-SR | wc -l  >> swqc-tmp/$SERIAL-part-count.txt
ifconfig -va | grep -i 25GBASE-SR | wc -l >> swqc-tmp/$SERIAL-diffme.txt
ifconfig -va | grep -i 25GBASE-SR | wc -l >> swqc-tmp/swqc-output.txt
#
#
fi
#
#
if echo "$PRODUCT" | grep -Fwqi -e "Product Name: TRUENAS-M60-S" ; then
#
echo "TrueNAS M60 Fan valadation" >> swqc-tmp/$SERIAL-diffme.txt
#
#
ipmitool sensor list | grep -Ei "FAN[34AB]" | cut -d\| -f1-3 >> swqc-tmp/$SERIAL-diffme.txt
#
#
fi
#
#
#
#
if echo "$PRODUCT" | grep -Fwqi -e "Product Name: TRUENAS-M60-S" && ipmitool raw 0x30 0x45 0x00 | grep -oh "\w*00\w*"| grep -Fwqi -e 00; then
#
echo "FAN Speed " >> swqc-tmp/$SERIAL-diffme.txt
#
ipmitool raw 0x30 0x45 0x00 > swqc-tmp/M60-fanspeed-txt
#
M60FANSPEED=$(cat swqc-tmp/M60-fanspeed-txt) 
#
echo "Correctly showing as $M60FANSPEED" >> swqc-tmp/$SERIAL-diffme.txt
#
#
elif echo "$PRODUCT"| grep -Eqi "Product Name: TRUENAS-M60-S"  && ipmitool raw 0x30 0x45 0x00 | grep -oh "\w*00*" != 00; then
#
#
M60FANSPEED=$(cat swqc-tmp/M60-fanspeed-txt) 
#
echo "showing as $M60FANSPEED it should be 00 ">> swqc-tmp/$SERIAL-diffme.txt
#
#
fi
#
#
#
echo "===============================" >> swqc-tmp/swqc-output.txt
#
#
#
if echo "$PRODUCT"| grep -Fwqi -e "Product Name: TRUENAS-M60-HA" && echo "$BIOVER" | grep -oh "\w*3.3aV3\w*"| grep -Fwqi -e 3.3aV3; then
#
#
echo "Checking TRUENAS-M60 bios version it should be 3.3aV3"
#
#
echo "Bios verson" >> swqc-tmp/$SERIAL-diffme.txt
echo "Bios version">> swqc-tmp/$SERIAL-part-count.txt
#
echo "Correctly showing as  3.3aV3"  >> swqc-tmp/swqc-output.txt
echo "Correctly showing as  3.3aV3"  > swqc-tmp/M60-bios.txt
echo "Correctly showing as  3.3aV3" >> swqc-tmp/$SERIAL-diffme.txt
echo "Correctly showing as  3.3aV3" >> $SERIAL-part-count.txt
echo "Bios verson" >> swqc-tmp/$SERIAL-PorF.txt
echo "pass" >> swqc-tmp/$SERIAL-PorF.txt
#
elif echo "$PRODUCT"| grep -Fwqi -e 'Product Name: TRUENAS-M60-HA' && echo "$BIOVER" | grep -oh "\w*3.3aV3\w*" != 3.3aV3; then
#
#
#
echo "Bios verson" >> swqc-tmp/$SERIAL-diffme.txt
echo "Bios version" >> swqc-tmp/$SERIAL-part-count.txt
#
echo "Bios version for TRUENAS-M60 is showing as $BIOVER it should be  3.3aV3" >> swqc-tmp/swqc-output.txt
echo "Bios version for TRUENAS-M60 is showing as $BIOVER it should be  3.3aV3" > swqc-tmp/M60-bios.txt
echo "Bios version for TRUENAS-M60 is showing as $BIOVER it should be  3.3aV3" >> swqc-tmp/warning.txt
echo "Showing as $BIOVER it should be  3.3aV3" >> swqc-tmp/$SERIAL-diffme.txt
echo "Bios version for TRUENAS-M60 is showing as $BIOVER it should be  3.3aV3" >> swqc-tmp/$SERIAL-part-count.txt
echo "Bios verson" >> swqc-tmp/$SERIAL-PorF.txt
echo "fail" >> swqc-tmp/$SERIAL-PorF.txt
#
#
M60BIOV=$(cat swqc-tmp/M60-bios.txt)
#
#
fi
#
#
if echo "$PRODUCT"| grep -Fwqi -e "Product Name: TRUENAS-M60-HA" && echo "$BMCINFO" | grep -oh "\w*6.73\w*"| grep -Fwqi -e 6.73; then
#
#
#
echo "BMC firmware" >> swqc-tmp/$SERIAL-diffme.txt
echo "BMC firmware" >> swqc-tmp/$SERIAL-part-count.txt
#
#
echo "BMC Firmware for TRUENAS-M60 should be 6.73"  >> swqc-tmp/swqc-output.txt
# 
#
echo "BMC firmware for TRUENAS-M60 is correctly showing as $BMCINFO it should be  6.73" >> swqc-tmp/swqc-output.txt
echo "BMC firmware for TRUENAS-M60 is correctly showing as $BMCINFO it should be  6.73" > swqc-tmp/M60-bmc.txt
echo "BMC firmware for TRUENAS-M60 is correctly showing as $BMCINFO it should be  6.73" >> swqc-tmp/$SERIAL-diffme.txt
echo "BMC firmware" >> swqc-tmp/$SERIAL-PorF.txt
echo "pass"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         
#
elif echo "$PRODUCT"| grep -Fwqi -e "Product Name: TRUENAS-M60-HA" && echo "$BMCINFO" | grep -oh "\w*6.73\w*" != 6.73; then
#
echo "BMC firmware for TRUENAS-M60 is showing as $BMCINFO it should be  6.73" >> swqc-tmp/swqc-output.txt
echo "BMC firmware for TRUENAS-M60 is showing as $BMCINFO it should be  6.73" > swqc-tmp/M60-bmc.txt
echo "BMC firmware for TRUENAS-M60 is showing as $BMCINFO it should be  6.73" >> swqc-tmp/warning.txt
echo "BMC firmware showing as $BMCINFO it should be  6.73">> swqc-tmp/$SERIAL-diffme.txt
echo "BMC firmware" >> swqc-tmp/$SERIAL-PorF.txt
echo "fail" >> swqc-tmp/$SERIAL-PorF.txt
#
#
#
M60BMC=$(cat swqc-tmp/M60-bmc.txt)
#
#
fi
#
#
#
#
#
# IX-TN-M60-HA-V.02
#
if echo "$PRODUCT" | grep -Fwqi -e "Product Name: TRUENAS-M60-HA" ; then
#
echo "TrueNAS M60 Specific valadation" >> swqc-tmp/swqc-output.txt
#
# Software Validation of x16 NTB
#
pciconf -lvcb ntb_hw0 | egrep 'PLX|8732|x16\(x16\) speed 8.0\(8.0\)' > swqc-tmp/ntb_hw0.txt
pciconf -lvcb ntb_hw0 | egrep 'PLX|8732|x16\(x16\) speed 8.0\(8.0\)'  >> swqc-tmp/swqc-output.txt
#
#
NTBHW0=$(cat swqc-tmp/ntb_hw0.txt)
#
#Ensure that the following 3 lines are returned by command:
#
# vendor     = 'PLX Technology, Inc.'
# device     = 'PEX 8732 32-lane, 8-Port PCI Express Gen 3 (8.0 GT/s) Switch'
# link x16(x16) speed 8.0(8.0) ASPM disabled(L0s/L1)
#
#
#  check the connection between both controllers NTB:
#  
#
grep ntb_hw /var/log/messages | grep "ntb_hw0: Link is up (PCIe 3.x / x16)" > swqc-tmp/ntb_hw0-link-status.txt # Note:if Single node controller result will be blank
grep ntb_hw /var/log/messages | grep "ntb_hw0: Link is up (PCIe 3.x / x16)" >> swqc-tmp/swqc-output.txt  # Note:if Single node controller result will be blank
#
#
NTBHW0linkstatus=$(cat swqc-tmp/ntb_hw0-link-status.txt)
#
# Ensure that "Link is up" message is returned
#
#
# NTB Window Size
#
pciconf -lvcb ntb_hw0 |egrep "bar.*\[18]"|cut -w -f 12-13 >> swqc-tmp/swqc-output.txt
pciconf -lvcb ntb_hw0 |egrep "bar.*\[18]"|cut -w -f 12-13 > swqc/ntb_hw0_windowsize.txt
#
#
NTBWINDOWSIZE=$(cat swqc/ntb_hw0_windowsize.txt)
#
#
# Size should be size    274877906944,
#
echo "===============================" >> swqc-tmp/swqc-output.txt
#
#
# “Cub” SAS Expander
# 
# 
# 
sesutil map  -u/dev/ses2 |grep LSISAS35 >> swqc-tmp/swqc-output.txt
sesutil map  -u/dev/ses2 |grep LSISAS35 > swqc-tmp/cubsas.txt
#
#
CUBSAS=$(cat swqc-tmp/cubsas.txt)
#
#
# Ran into issue with 10 jbods ses6 was the cub sas expander we needed to check here is how i want to resolve this.
#
# camcontrol devlist | cut -d, -f2 | tr -d \) | grep -i ses | xargs -I SES sesutil map  -u/dev/SES |grep LSISAS35 >> swqc-tmp/swqc-output.txt
# camcontrol devlist | cut -d, -f2 | tr -d \) | grep -i ses | xargs -I SES sesutil map  -u/dev/SES |grep LSISAS35 >> swqc-tmp/cubsas.txt
#
# Ensure the following is returned  Description: H24R-3X.R2D (LSISAS35Exp) 
#
echo "===============================" >> swqc-tmp/swqc-output.txt
#
# Software Validation of 12x 64 GiB ECC RDIMMsfor for TrueNAS M60 
# populating the blue memory slots on the X11DPi-NT board
#
dmidecode -t memory |grep Part|grep M393A8G40MB2-CVF|wc -l >> swqc-tmp/swqc-output.txt
dmidecode -t memory |grep Part|grep M393A8G40MB2-CVF|wc -l > swqc-tmp/M60_memory_count.txt
#
M60MEMCOUNT=$(cat swqc-tmp/M60_memory_count.txt) 
#
# Validate the output is 12 as that is the number of 64GB RDimms installed:
#
#
# 
#
dmidecode -t memory|grep "^[[:blank:]]Locator:\|Part"|grep -B1 M393A8G40MB2 |grep Locator >> swqc-tmp/swqc-output.txt
dmidecode -t memory|grep "^[[:blank:]]Locator:\|Part"|grep -B1 M393A8G40MB2 |grep Locator > swqc-tmp/M60-ram-slot-check.txt
#
#
# M60RAMSLOTS=$(cat swqc-tmp/M60-ram-slot-check.txt)
#
# Valadate that the ram is in the correct solts 
#
#
#
echo "===============================" >> swqc-tmp/swqc-output.txt
#
#
#
#
dmidecode -t memory |grep Part|grep 36ASS4G72PF12G9PR1AB |wc -l >> swqc-tmp/swqc-output.txt
dmidecode -t memory |grep Part|grep 36ASS4G72PF12G9PR1AB |wc -l > swqc-tmp/M60-nvdimm-valadation.txt
#
#If something other the 2 is returned, then there may be a serious configuration issue and the issue must be investigated and resolved

#
M60NVDIMMVALADATION=$(cat swqc-tmp/M60-nvdimm-valadation.txt)
#
#
echo "===============================" >> swqc-tmp/swqc-output.txt
#
# Validate that both NVDIMMs setup to sync across NTB
#
#
dmesg |grep 'NTB PMEM syncer'  >> swqc-tmp/swqc-output.txt
dmesg |grep 'NTB PMEM syncer' > swqc-tmp/nvdimm-sync-ntb.txt
#
#
M60NBDIMMSYNC=$(cat swqc-tmp/nvdimm-sync-ntb.txt)
#
# If only one PMEM syncer appears, you may be missing the required loader tunables that enable dual PMEM.
# If no NTB syncers appear, then there may be a serious configuration issue and the issue must be investigated and resolved
#
#
echo "===============================" >> swqc-tmp/swqc-output.txt
#
#
# Ensure that the NVDIMM is in the correct slots
#
dmidecode -t memory|grep "^[[:blank:]]Locator:\|Part"|grep -B1 18ASF2G72PF12G9WP1AB|grep Locator >> swqc-tmp/swqc-output.txt
dmidecode -t memory|grep "^[[:blank:]]Locator:\|Part"|grep -B1 18ASF2G72PF12G9WP1AB|grep Locator > swqc-tm-/M60-nvdimm-slot-check.txt
#
#
M60NVDIMMSLOTS=$(cat swqc-tm-/M60-nvdimm-slot-check.txt)
#
# Note: The ram should be in slots A2 on the first processor P1
#
#
#
echo "===============================" >> swqc-tmp/swqc-output.txt
#
#
# M60 Fan valadation
#
#
ipmitool sensor list | egrep "FAN[34AB]" | cut -d\| -f1-3  >> swqc-tmp/swqc-output.txt
ipmitool sensor list | egrep "FAN[34AB]" | cut -d\| -f1-3 > swqc-tmp/M60-FAN-RPM-CHECK.txt
#
M60FANRPM=$(cat swqc-tmp/M60-FAN-RPM-CHECK.txt)
#
#
#Validate the output shows FAN3 as na
#
#
echo "===============================" >> swqc-tmp/swqc-output.txt
#
# DCMI Power Reading  >> swqc-tmp/swqc-output.txt
#
#
ipmitool dcmi power reading  >> swqc-tmp/swqc-output.txt
ipmitool dcmi power reading  > swqc-tmp/m60dcmi-power-reading.txt
#
#
#
M60DCIPOW=$(cat swqc-tmp/m60dcmi-power-reading.txt) 
#
#
#
echo "===============================" >> swqc-tmp/swqc-output.txt
#
# 
# Software Validation of PMBUS
#
#
ipmitool sensor list|grep '^PS' >> swqc-tmp/swqc-output.txt
ipmitool sensor list|grep '^PS' > swqc-tmp/m60pmbus.txt
#
#
M60PMBUS=$(cat swqc-tmp/m60pmbus.txt)
#
# Ensure that both power supplies are listed and have status of 0x1:
#
#
echo "===============================" >> swqc-tmp/swqc-output.txt
#
#
# Ensure that the M60 Fans are set to standard
#
#
ipmitool raw 0x30 0x45 0x00 >> swqc-tmp/swqc-output.txt
ipmitool raw 0x30 0x45 0x00 > swqc-tm-/M60-fan-Setting-check.txt
#
M60FANSETTINGS=$(cat swqc-tm-/M60-fan-Setting-check.txt)
#
#It should return 00
#
fi 
#
#
#
#
if echo "$PRODUCT"| grep -Fwqi -e "Product Name: TRUENAS-M60-HA" && pciconf -lvcb | grep -oh "\w*T6225-SO-CR\w*"| grep -Fwqi -e T6225-SO-CR; then
echo "Add on nic card" >> swqc-tmp/swqc-output.txt
echo "Add on nic card" >> swqc-tmp/$SERIAL-diffme.txt
echo "Add on nic card" >> swqc-tmp/$SERIAL-part-count.txt
#
#pciconf -lvcb | grep -i T6225-SO-CR | wc -l > swqc-tmp/M60-add-on-nic-count.txt
pciconf -lvcb | grep -i T6225-SO-CR | wc -l  >> swqc-tmp/$SERIAL-part-count.txt
#pciconf -lvcb | grep -i T6225-SO-CR | wc -l  >> swqc-tmp/M60-25GB-nic-list-part.txt
pciconf -lvcb | grep -i T6225-SO-CR | wc -l  >> swqc-tmp/$SERIAL-diffme.txt
pciconf -lvcb | grep -i T6225-SO-CR | wc -l >> swqc-tmp/swqc-output.txt
#
#
fi
#
#
#
if echo "$PRODUCT"| grep -Fwqi -e "Product Name: TRUENAS-M60-HA" && pciconf -lvcb | grep -oh "\w*T62100-LP-CR\w*"| grep -Fwqi -e T62100-LP-CR; then
echo "Add on nic card" >> swqc-tmp/swqc-output.txt
echo "Add on nic card" >> swqc-tmp/$SERIAL-diffme.txt
echo "Add on nic card" >> swqc-tmp/$SERIAL-part-count.txt
#
pciconf -lvcb | grep -i T62100-LP-CR | wc -l > swqc-tmp/M60-add-on-nic-count.txt
pciconf -lvcb | grep -i T62100-LP-CR | wc -l  >> swqc-tmp/$SERIAL-part-count.txt
pciconf -lvcb | grep -i T62100-LP-CR| wc -l  >> swqc-tmp/$SERIAL-diffme.txt
pciconf -lvcb | grep -i T62100-LP-CR| wc -l >> swqc-tmp/swqc-output.txt
#
#
fi
#
#
#
#
#
if echo "$PRODUCT"| grep -Fwqi -e "Product Name: TRUENAS-M60-HA" && ifconfig -va | grep -oh "\w*SM10G-SR\w*"| grep -Fwqi -e SM10G-SR; then
echo "10G SFP Count" >> swqc-tmp/swqc-output.txt
echo "10G SFP Count" >> swqc-tmp/$SERIAL-diffme.txt
echo "10G SFP Count" >> swqc-tmp/$SERIAL-part-count.txt
#
ifconfig -va | grep -i SM10G-SR| wc -l > swqc-tmp/M60-10G-SFP-count.txt
ifconfig -va | grep -i SM10G-SR > swqc-tmp/M60-10G-SFP-list.txt
ifconfig -va | grep -i SM10G-SR | wc -l  >> swqc-tmp/$SERIAL-part-count.txt
ifconfig -va | grep -i SM10G-SR | wc -l >> swqc-tmp/$SERIAL-diffme.txt
ifconfig -va | grep -i SM10G-SR | wc -l >> swqc-tmp/swqc-output.txt
#
#
fi
#
#
#
if echo "$PRODUCT"| grep -Fwqi -e "Product Name: TRUENAS-M60-HA" && ifconfig -va | grep -oh "\w*25GBASE-SR\w*"| grep -Fwqi -e 25GBASE-SR; then
echo "25G SFP Count" >> swqc-tmp/swqc-output.txt
echo "25G SFP Count" >> swqc-tmp/$SERIAL-diffme.txt
echo "25G SFP Count" >> swqc-tmp/$SERIAL-part-count.txt
#
ifconfig -va | grep -i 25GBASE-SR| wc -l > swqc-tmp/M60-25G-SFP-count.txt
ifconfig -va | grep -i 25GBASE-SR > swqc-tmp/M60-25G-SFP-list.txt
ifconfig -va | grep -i 25GBASE-SR | wc -l  >> swqc-tmp/$SERIAL-part-count.txt
ifconfig -va | grep -i 25GBASE-SR | wc -l >> swqc-tmp/$SERIAL-diffme.txt
ifconfig -va | grep -i 25GBASE-SR | wc -l >> swqc-tmp/swqc-output.txt
#
#
fi
#
#
#
if echo "$PRODUCT"| grep -Fwqi -e "Product Name: TRUENAS-M60-HA" && ifconfig -va | grep -oh "\w*QSFP-SR4-40G\w*"| grep -Fwqi -e QSFP-SR4-40G; then
echo "40G SFP Count" >> swqc-tmp/swqc-output.txt
echo "40G SFP Count" >> swqc-tmp/$SERIAL-diffme.txt
echo "40G SFP Count" >> swqc-tmp/$SERIAL-part-count.txt
#
ifconfig -va | grep -i QSFP-SR4-40G | wc -l > swqc-tmp/M60-40G-SFP-count.txt
ifconfig -va | grep -i QSFP-SR4-40G > swqc-tmp/M60-40G-SFP-list.txt
ifconfig -va | grep -i QSFP-SR4-40G | wc -l  >> swqc-tmp/$SERIAL-part-count.txt
ifconfig -va | grep -i QSFP-SR4-40G | wc -l >> swqc-tmp/$SERIAL-diffme.txt
ifconfig -va | grep -i QSFP-SR4-40G | wc -l >> swqc-tmp/swqc-output.txt
#
#
fi
#
#
if echo "$PRODUCT" | grep -Fwqi -e "Product Name: TRUENAS-M60-HA" ; then
#
echo "TrueNAS M60 Fan valadation" >> swqc-tmp/$SERIAL-diffme.txt
#
#
ipmitool sensor list | grep -Ei "FAN[34AB]" | cut -d\| -f1-3 >> swqc-tmp/$SERIAL-diffme.txt
#
#
fi
#
#
#
#
if echo "$PRODUCT" | grep -Fwqi -e "Product Name: TRUENAS-M60-HA" && ipmitool raw 0x30 0x45 0x00 | grep -oh "\w*00\w*"| grep -Fwqi -e 00; then
#
echo "FAN Speed " >> swqc-tmp/$SERIAL-diffme.txt
#
ipmitool raw 0x30 0x45 0x00 > swqc-tmp/M60-fanspeed-txt
#
M60FANSPEED=$(cat swqc-tmp/M60-fanspeed-txt) 
#
echo "Correctly showing as $M60FANSPEED" >> swqc-tmp/$SERIAL-diffme.txt
#
#
elif echo "$PRODUCT"| grep -Eqi "Product Name: TRUENAS-M60-HA"  && ipmitool raw 0x30 0x45 0x00 | grep -oh "\w*00*" != 00; then
#
echo "FAN Speed " >> swqc-tmp/$SERIAL-diffme.txt
#
M60FANSPEED=$(cat swqc-tmp/M60-fanspeed-txt) 
#
echo "showing as $M60FANSPEED it should be 00 ">> swqc-tmp/$SERIAL-diffme.txt
#
#
fi
#
#
#
#
#
echo "point check E" >> swqc-tmp/swqc-output.txt
echo "point check E" > swqc-tmp/pointcheck-E.txt
#
echo "===============================" >> swqc-tmp/swqc-output.txt
#
# TRUENAS-MINI-3.0-E
# 
# 
#
if echo "$PRODUCT" | grep -Eqi 'TRUENAS-MINI-3.0-E$'; then
#
# 
#
echo "TRUENAS-MINI-3.0-E fan info" >> swqc-tmp/swqc-output.txt
echo "Fan connectors FRNT_FAN1 ,FRNT_FAN2 are NOT to be connected. "
echo "Fan connectors FRNT_FAN1 ,FRNT_FAN2,are NOT to be connected. " >> swqc-tmp/swqc-output.txt
ipmitool sensor list | grep -Ei 'CPU1_FAN1|REAR_FAN1' >> swqc-tmp/swqc-output.txt
ipmitool sensor list | grep -Ei 'CPU1_FAN1|REAR_FAN1' >  swqc-tmp/mini-efan-output.txt
echo "Fan Threshold settings" >> swqc-tmp/$SERIAL-diffme.txt
ipmitool sensor list | grep -Ei 'CPU1_FAN1|REAR_FAN1' >> swqc-tmp/$SERIAL-part-count.txt
 ipmitool sensor list | grep -Ei 'CPU1_FAN1|REAR_FAN1' | grep -Ei 'cpu1_fan1|rear_fan1'| cut -d "|" -f1 -f2 -f3 -f4 -f7 >> swqc-tmp/$SERIAL-diffme.txt
echo "Sensor List" >> swqc-tmp/parts-list.txt
ipmitool sensor list | grep -Ei 'CPU1_FAN1|REAR_FAN1' >> swqc-tmp/parts-list.txt
#
#
MINIEFAN=$(cat swqc-tmp/mini-efan-output.txt)
#
echo "$MINIEFAN" >> swqc-tmp/$SERIAL-part-count.txt
#
ipmitool sdr list | grep -Ei 'CPU1_FAN1|REAR_FAN1' >> swqc-tmp/swqc-output.txt
ipmitool sdr list | grep -Ei 'CPU1_FAN1|REAR_FAN1' >  swqc-tmp/mini-esdr-output.txt
#
MINIESDR=$(cat swqc-tmp/mini-esdr-output.txt)
#
#
echo "$MINIESDR" >> swqc-tmp/$SERIAL-part-count.txt
#
fi
#
#
# Bios for TRUENAS-MINI-3.0-E  should be L1.11C
#
if echo "$PRODUCT"| grep -Eqi 'TRUENAS-MINI-3.0-E$' && echo "$BIOVER" | grep -oh "\w*L1.11C\w*"| grep -Fwqi -e L1.11C; then
#
echo "Bios version for TRUENAS-MINI-3.0-E is correctly showing as L1.11C"  >> swqc-tmp/swqc-output.txt
echo "Bios version for TRUENAS-MINI-3.0-E  is correctly showing as L1.11C"  > swqc-tmp/mini-ebios.txt
echo "Bios version for TRUENAS-MINI-3.0-E  is correctly showing as L1.11C" >> swqc-tmp/$SERIAL-part-count.txt
echo "Bios Version" >> swqc-tmp/parts-list.txt
echo "Bios version for TRUENAS-MINI-3.0-E  is correctly showing as L1.11C" >> swqc-tmp/parts-list.txt
echo "Bios Version" >> swqc-tmp/$SERIAL-diffme.txt
echo "Correctly showing as L1.11C" >> swqc-tmp/$SERIAL-diffme.txt
echo "Bios verson" >> swqc-tmp/$SERIAL-PorF.txt
echo "pass" >> swqc-tmp/$SERIAL-PorF.txt
#
elif echo "$PRODUCT"| grep -Eqi 'TRUENAS-MINI-3.0-E $' && echo "$BIOVER" | grep -oh "\w*L1.11C*" != L1.11C; then
#
echo "Bios version for TRUENAS-MINI-3.0-E  is showing as $BIOVER it should be  L1.11C" >> swqc-tmp/swqc-output.txt
echo "Bios version for TRUENAS-MINI-3.0-E  is showing as $BIOVER it should be  L1.11C" > swqc-tmp/mini-ebios.txt
echo "Bios version for TRUENAS-MINI-3.0-E  is showing as $BIOVER it should be  L1.11C" >> swqc-tmp/warning.txt
echo "Bios version for TRUENAS-MINI-3.0-E  is showing as $BIOVER it should be  L1.11C" >> swqc-tmp/$SERIAL-part-count.txt
echo "Bios Version" >> swqc-tmp/parts-list.txt
echo "Bios version for TRUENAS-MINI-3.0-E  is showing as $BIOVER it should be  L1.11C" >> swqc-tmp/parts-list.txt
echo "Bios Version" >> swqc-tmp/$SERIAL-diffme.txt
echo "Bios version is $BIOVER it should be  L1.11C" >> swqc-tmp/$SERIAL-diffme.txt
echo "Bios verson" >> swqc-tmp/$SERIAL-PorF.txt
echo "fail" >> swqc-tmp/$SERIAL-PorF.txt
#
#
MINIEBIOV=$(cat swqc-tmp/mini-ebios.txt)
#
#
fi
#
#
# BMC Firmware for TRUENAS-MINI-3.0-E should be 1.0
#
#
#
if echo "$PRODUCT"| grep -Eqi 'TRUENAS-MINI-3.0-E$' && echo "$BMCINFO" | grep -oh "\w*1.00\w*"| grep -Fwqi -e 1.00; then
#
echo "BMC firmware for TRUENAS-MINI-3.0-E is correctly showing as 1.0"  >> swqc-tmp/swqc-output.txt
echo "BMC firmware for TRUENAS-MINI-3.0-E  is correctly showing as 1.0"  > swqc-tmp/mini-ebmc.txt
echo "BMC firmware for TRUENAS-MINI-3.0-E  is correctly showing as 1.0" >> swqc-tmp/$SERIAL-part-count.txt
echo "BMC Firmware" >> swqc-tmp/parts-list.txt
echo "BMC firmware for TRUENAS-MINI-3.0-E  is correctly showing as 1.0" >> swqc-tmp/parts-list.txt
echo "BMC Firmware" >> swqc-tmp/$SERIAL-diffme.txt
echo "Correctly showing as 1.0" >> swqc-tmp/$SERIAL-diffme.txt
#
elif echo "$PRODUCT"| grep -Eqi 'TRUENAS-MINI-3.0-E $' && echo "$BMCINFO" | grep -oh "\w*1.00*" != 1.00; then
#
echo "BMC firmware for TRUENAS-MINI-3.0-E  is showing as $BMCINFO it should be  1.00" >> swqc-tmp/swqc-output.txt
echo "BMC firmware for TRUENAS-MINI-3.0-E  is showing as $BMCINFO it should be  1.00" > swqc-tmp/mini-ebmc.txt
echo "BMC firmware for TRUENAS-MINI-3.0-E  is showing as $BMCINFO it should be  1.00" >> swqc-tmp/warning.txt
echo "BMC firmware for TRUENAS-MINI-3.0-E  is showing as $BMCINFO it should be  1.00" >> swqc-tmp/$SERIAL-part-count.txt
echo "BMC Firmware" >> swqc-tmp/parts-list.txt
echo "BMC firmware for TRUENAS-MINI-3.0-E  is showing as $BMCINFO it should be  1.00" >> swqc-tmp/parts-list.txt
echo "BMC Firmware" >> swqc-tmp/$SERIAL-diffme.txt
echo "BMC firmware is $BMCINFO it should be  1.00" >> swqc-tmp/$SERIAL-diffme.txt
#
MINIEBMC=$(cat swqc-tmp/mini-ebmc.txt)
#
#
fi
#
#
#
echo "point check F" >> swqc-tmp/swqc-output.txt
echo "point check F" > swqc-tmp/pointcheck-F.txt
#
#
#
echo "===============================" >> swqc-tmp/swqc-output.txt
#
#
#
# TRUENAS-MINI-3.0-E+ ( under testing ) 
#
if echo "$PRODUCT"|grep -Fwqi -e TRUENAS-MINI-3.0-E+ ; then
#
echo "TRUENAS-MINI-3.0-E+ Fan Info "  >> swqc-tmp/swqc-output.txt
echo echo "Fan connectors FRNT_FAN1,FRNT_FAN2,are NOT to be connected. "
echo echo "Fan connectors FRNT_FAN1,FRNT_FAN2,are NOT to be connected. " >> swqc-tmp/swqc-output.txt
ipmitool sensor list | grep -i 'REAR_FAN1' >> swqc-tmp/swqc-output.txt
ipmitool sensor list | grep -i 'REAR_FAN1' >  swqc-tmp/mini-e-plusfan-output.txt
#
MINIEPLUSFAN=$( cat swqc-tmp/mini-e-plusfan-output.txt)
#
#
#
ipmitool sdr list | grep -i 'REAR_FAN1' > swqc-tmp/mini-e-plus-sdrout.txt
ipmitool sdr list | grep -i 'REAR_FAN1' >> swqc-tmp/swqc-output.txt
#
#
#
MINIEPLUSSDR=$( cat swqc-tmp/mini-e-plus-sdrout.txt)
#
fi
#
if echo "$MINIEPLUSSDR" | grep -Fwqi  -e "no reading" ; then 
#
#
echo "The following FAN(s) show no reading" > swqc-tmp/mini-e-plus-fan-errors.txt
echo "The following FAN(s) show no reading" >> swqc-tmp/swqc-output.txt
cat swqc-tmp/mini-e-plus-sdrout.txt | grep -i "no reading" >> swqc-tmp/swqc-output.txt
cat swqc-tmp/mini-e-plus-sdrout.txt | grep -i "no reading" >> swqc-tmp/mini-e-plus-fan-errors.txt
#
MINIEPLUSFAN-ERRORS=$(cat swqc-tmp/mini-e-plus-fan-errors.txt)
#
fi
#
#
#
#
#
#
echo "===============================" >> swqc-tmp/swqc-output.txt
#
# 
# TRUENAS-MINI-3.0-X 
# 
# 
#
if echo "$PRODUCT" | grep -Eqi 'Product Name: TRUENAS-MINI-3.0-X'; then
#
# 
#
echo "TRUENAS-MINI-3.0-X fan info" >> swqc-tmp/swqc-output.txt
echo "Fan connectors FRNT_FAN1 ,FRNT_FAN2 are NOT to be connected. "
echo "Fan connectors FRNT_FAN1 ,FRNT_FAN2,are NOT to be connected. " >> swqc-tmp/swqc-output.txt
ipmitool sensor list | grep -Ei 'CPU1_FAN1|REAR_FAN1' >> swqc-tmp/swqc-output.txt
ipmitool sensor list | grep -Ei 'CPU1_FAN1|REAR_FAN1' >  swqc-tmp/mini-xfan-output.txt
echo "Fan Threshold settings" >> swqc-tmp/$SERIAL-diffme.txt
ipmitool sensor list | grep -Ei 'CPU1_FAN1|REAR_FAN1' >> swqc-tmp/$SERIAL-part-count.txt
 ipmitool sensor list | grep -Ei 'CPU1_FAN1|REAR_FAN1' | grep -Ei 'cpu1_fan1|rear_fan1'| cut -d "|" -f1 -f2 -f3 -f4 -f7 >> swqc-tmp/$SERIAL-diffme.txt
echo "Sensor List" >> swqc-tmp/parts-list.txt
ipmitool sensor list | grep -Ei 'CPU1_FAN1|REAR_FAN1' >> swqc-tmp/parts-list.txt
#
MINIXFAN=$(cat swqc-tmp/mini-xfan-output.txt)
#
#
ipmitool sdr list | grep -Ei 'CPU1_FAN1|REAR_FAN1' >> swqc-tmp/swqc-output.txt
ipmitool sdr list | grep -Ei 'CPU1_FAN1|REAR_FAN1' >  swqc-tmp/mini-xsdr-output.txt
ipmitool sdr list | grep -Ei 'CPU1_FAN1|REAR_FAN1' >> swqc-tmp/$SERIAL-part-count.txt
echo "SDR List" >> swqc-tmp/parts-list.txt
ipmitool sdr list | grep -Ei 'CPU1_FAN1|REAR_FAN1'>> swqc-tmp/parts-list.txt
#
MINIXSDR=$(cat swqc-tmp/mini-xsdr-output.txt)
#
fi
#
#
# Bios for TRUENAS-MINI-3.0-X should be L1.42A
#
if echo "$PRODUCT"| grep -Eqi 'Product Name: TRUENAS-MINI-3.0-X$' && echo "$BIOVER" | grep -oh "\w*L1.42A\w*"| grep -Fwqi -e L1.42A; then
#
echo "Bios version for TRUENAS-MINI-3.0-X is correctly showing as L1.42A"  >> swqc-tmp/swqc-output.txt
echo "Bios version for TRUENAS-MINI-3.0-X is correctly showing as L1.42A"  > swqc-tmp/mini-xbios.txt
echo "Bios version for TRUENAS-MINI-3.0-X is correctly showing as L1.42A"  >> swqc-tmp/$SERIAL-part-count.txt
echo "Bios Version" >> swqc-tmp/parts-list.txt
echo "Bios version for TRUENAS-MINI-3.0-X is correctly showing as L1.42A" >> swqc-tmp/parts-list.txt
echo "Bios Version" >> swqc-tmp/$SERIAL-diffme.txt
echo "Correctly showing as L1.42A" >> swqc-tmp/$SERIAL-diffme.txt
echo "Bios verson" >> swqc-tmp/$SERIAL-PorF.txt
echo "pass" >> swqc-tmp/$SERIAL-PorF.txt
#
#
elif echo "$PRODUCT"| grep -Eqi 'Product Name: TRUENAS-MINI-3.0-X$' && echo "$BIOVER" | grep -oh "\w*L1.42A"\w*" != L1.42A"; then
#
echo "Bios version for TRUENAS-MINI-3.0-X is showing as $BIOVER it should be  L1.42A" >> swqc-tmp/swqc-output.txt
echo "Bios version for TRUENAS-MINI-3.0-X is showing as $BIOVER it should be  L1.42A" > swqc-tmp/mini-xbios.txt
echo "Bios version for TRUENAS-MINI-3.0-X is showing as $BIOVER it should be  L1.42A" >> swqc-tmp/warning.txt
echo "Bios version for TRUENAS-MINI-3.0-X is showing as $BIOVER it should be  L1.42A" >> swqc-tmp/$SERIAL-part-count.txt
echo "Bios Version" >> swqc-tmp/parts-list.txt
echo "Bios version for TRUENAS-MINI-3.0-X is showing as $BIOVER it should be  L1.42A" >> swqc-tmp/parts-list.txt
echo "Bios Version" >> swqc-tmp/$SERIAL-diffme.txt
echo "Bios version is $BIOVER it should be  L1.42A" >> swqc-tmp/$SERIAL-diffme.txt
echo "Bios verson" >> swqc-tmp/$SERIAL-PorF.txt
echo "fail" >> swqc-tmp/$SERIAL-PorF.txt
#
#
MINIXBIOV=$(cat swqc-tmp/mini-xbios.txt)
#
#
fi
#
#
# BMC for TRUENAS-MINI-3.0-X should be 1.60
#
if echo "$PRODUCT"| grep -Eqi 'Product Name: TRUENAS-MINI-3.0-X$' && echo "$BMCINFO" | grep -oh "\w*1.60\w*"| grep -Fwqi -e 1.60; then
#
echo "BMC firmware for TRUENAS-MINI-3.0-X is correctly showing as 1.60" >> swqc-tmp/swqc-output.txt
echo "BMC firmware for TRUENAS-MINI-3.0-X is correctly showing as 1.60" > swqc-tmp/mini-xbmc.txt
echo "BMC firmware for TRUENAS-MINI-3.0-X is correctly showing as 1.60" >> swqc-tmp/$SERIAL-part-count.txt
echo "BMC firmware" >> swqc-tmp/parts-list.txt
echo "BMC firmware for TRUENAS-MINI-3.0-X is correctly showing as 1.60" >> swqc-tmp/parts-list.txt
echo "BMC firmware" >> swqc-tmp/$SERIAL-diffme.txt
echo "Correctly showing as 1.60" >> swqc-tmp/$SERIAL-diffme.txt
echo "BMC firmware" >> swqc-tmp/$SERIAL-PorF.txt
echo "pass" >> swqc-tmp/$SERIAL-PorF.txt
#
elif echo "$PRODUCT"| grep -Eqi 'Product Name: TRUENAS-MINI-3.0-X$' && echo "$BMCINFO" | grep -oh "\w*1.60\w*" != 1.60; then
#
echo "BMC firmware for TRUENAS-MINI-3.0-X is showing as $BMCINFO it should be  1.60" >> swqc-tmp/swqc-output.txt
echo "BMC firmware for TRUENAS-MINI-3.0-X is showing as $BMCINFO it should be  1.60" > swqc-tmp/mini-xbmc.txt
echo "BMC firmware for TRUENAS-MINI-3.0-X is showing as $BMCINFO it should be  1.60" >> swqc-tmp/warning.txt
echo "BMC firmware for TRUENAS-MINI-3.0-X is showing as $BMCINFO it should be  1.60" >> swqc-tmp/$SERIAL-part-count.txt
echo "BMC firmware" >> swqc-tmp/parts-list.txt
echo "BMC firmware for TRUENAS-MINI-3.0-X is showing as $BMCINFO it should be  1.60" >> swqc-tmp/parts-list.txt
echo "BMC firmware" >> swqc-tmp/$SERIAL-diffme.txt
echo "BMC firmware is $BMCINFO it should be  1.60" >> swqc-tmp/$SERIAL-diffme.txt
echo "BMC firmware" >> swqc-tmp/$SERIAL-PorF.txt                                                                                                                                                                                                                                                   
echo "fail" >> swqc-tmp/$SERIAL-PorF.txt
#
#
XBMCINFO=$(cat swqc-tmp/mini-xbmc.txt)
#
#
#
#
fi
#
#
#
#
#
#
if echo "$PRODUCT"| grep -Fwqi -e 'Product Name: TRUENAS-MINI-3.0-X$'  && pciconf -lvcb | grep -oh "\w*T520\w*"| grep -Fwqi -e T520; then
echo "Add on nic card" >> swqc-tmp/swqc-output.txt
echo "Add on nic card" >> swqc-tmp/$SERIAL-diffme.txt
echo "Add on nic card" >> swqc-tmp/$SERIAL-part-count.txt
#
pciconf -lvcb | grep -i T520 | wc -l > swqc-tmp/10G-add-on-nic-count.txt
pciconf -lvcb | grep -i T520 > swqc-tmp/10G-add-on-nic-list.txt
pciconf -lvcb | grep -i T520 | wc -l  >> swqc-tmp/$SERIAL-part-count.txt
pciconf -lvcb | grep -i T520| wc -l  >> swqc-tmp/$SERIAL-diffme.txt
pciconf -lvcb | grep -i T520| wc -l >> swqc-tmp/swqc-output.txt
#
#
fi
#
#
#
#
#
echo "point check G" >> swqc-tmp/swqc-output.txt
echo "point check G" > swqc-tmp/pointcheck-G.txt
#
#
#
echo "===============================" >> swqc-tmp/swqc-output.txt
#
echo "===============================" >> swqc-tmp/$SERIAL-part-count.txt
echo "===============================" >> swqc-tmp/$SERIAL-part-count.txt
#
#
# XL+ needs all 3 FAN thresholds to bet set at 200 300 500
# 
#
if echo "$PRODUCT"| grep -Fwqi -e TRUENAS-MINI-3.0-XL+; then
#
echo "XL+ needs all 3 FAN thresholds to bet set at 200 300 500" >> swqc-tmp/$SERIAL-part-count.txt
#
#
#
#
echo "FAN Thresholds" >> swqc-tmp/$SERIAL-diffme.txt
ipmitool sensor list | grep -i 'FAN[A12]'| cut -d "|" -f1 -f5 -f6 -f7  >> swqc-tmp/swqc-output.txt
ipmitool sensor list | grep -i 'FAN[A12]'| cut -d "|" -f1 -f5 -f6 -f7  >  swqc-tmp/xlplusfan-output.txt
ipmitool sensor list | grep -i 'FAN[A12]'| cut -d "|" -f1 -f5 -f6 -f7  >> swqc-tmp/$SERIAL-part-count.txt
ipmitool sensor list | grep -i 'FAN[A12]'| cut -d "|" -f1 -f5 -f6 -f7  >> swqc-tmp/parts-list.txt
ipmitool sensor list | grep -i 'FAN[A12]'| cut -d "|" -f1 -f5 -f6 -f7  >> swqc-tmp/$SERIAL-diffme.txt
#
XLPLUSFAN=$(cat swqc-tmp/xlplusfan-output.txt)
#
#
#
fi
#
if echo "$PRODUCT"| grep -Fwqi -e TRUENAS-MINI-3.0-XL+; then
#
echo "TRUENAS-MINI-3.0-XL+" >> swqc-tmp/swqc-output.txt
#
#
ipmitool sdr list | grep -i 'FAN[A123]' >> swqc-tmp/swqc-output.txt
ipmitool sdr list | grep -i 'FAN[A123]' >  swqc-tmp/xlplusfan-sdr-output.txt
ipmitool sdr list | grep -i 'FAN[A123]' >  swqc-tmp/xlplusfsdr-output.txt
ipmitool sdr list | grep -i 'FAN[A123]' >> swqc-tmp/$SERIAL-part-count.txt
ipmitool sdr list | grep -i 'FAN[A123]' >> swqc-tmp/parts-list.txt
#
XLPLUSFANSDR=$(cat swqc-tmp/xlplusfan-sdr-output.txt)
#
#
echo "$XLPLUSFAN" >> swqc-tmp/$SERIAL-part-count.txt
#
#
#
ipmitool sensor list | grep -i 'FAN[A123]' >> swqc-tmp/swqc-output.txt
ipmitool sensor list | grep -i 'FAN[A123]' >  swqc-tmp/xlplusfan-output.txt
ipmitool sensor list | grep -i 'FAN[A123]' >> swqc-tmp/$SERIAL-part-count.txt
ipmitool sensor list | grep -i 'FAN[A123]' >> swqc-tmp/parts-list.txt
#
XLPLUSFAN=$(cat swqc-tmp/xlplusfan-output.txt)
#
#
#
fi
#
#
ipmitool sensor list

#
#
echo "===============================" >> swqc-tmp/$SERIAL-part-count.txt
echo "===============================" >> swqc-tmp/$SERIAL-part-count.txt
#
# Bios for TRUENAS-MINI-3.0-XL+ should be 1.3V1
#
#
if echo "$PRODUCT"| grep -Fwqi -e TRUENAS-MINI-3.0-XL+ && echo "$BIOVER" | grep -oh "\w*1.3.V1\w*"| grep -Fwqi -e 1.3.V1; then
#
echo "TRUENAS-MINI-3.0-XL+ BIOS information" >> swqc-tmp/$SERIAL-part-count.txt
echo "Bios version for TRUENAS-MINI-3.0-XL+ is correctly showing as 1.3V1"  >> swqc-tmp/swqc-output.txt
echo "Bios version for TRUENAS-MINI-3.0-XL+ is correctly showing as 1.3V1"  > swqc-tmp/xlplussbios.txt
echo "Bios version for TRUENAS-MINI-3.0-XL+ is correctly showing as 1.3V1"  >> swqc-tmp/$SERIAL-part-count.txt
echo "Bios Version"  >> swqc-tmp/parts-list.txt
echo "Bios version for TRUENAS-MINI-3.0-XL+ is correctly showing as 1.3V1" >> swqc-tmp/parts-list.txt
echo "Bios Version" >> swqc-tmp/$SERIAL-diffme.txt
echo "Correctly showing as 1.3V1" >> swqc-tmp/$SERIAL-diffme.txt
echo "Bios Version" >> swqc-tmp/$SERIAL-PorF.txt
echo "pass" >> swqc-tmp/$SERIAL-PorF.txt
#
#
elif echo "$PRODUCT"| grep -Fwqi -e TRUENAS-MINI-3.0-XL+ && echo "$BIOVER" | grep -oh "\w*1.3.V1\w*" != 1.3.V1; then
#
echo "Bios version for TRUENAS-MINI-3.0-XL+ is showing as $BIOVER it should be  1.3V1" >> swqc-tmp/swqc-output.txt
echo "Bios version for TRUENAS-MINI-3.0-XL+ is showing as $BIOVER it should be  1.3V1" > swqc-tmp/xlplussbios.txt
echo "Bios version for TRUENAS-MINI-3.0-XL+ is showing as $BIOVER it should be  1.3V1" >> swqc-tmp/warning.txt
echo "Bios version for TRUENAS-MINI-3.0-XL+ is showing as $BIOVER it should be  1.3V1" >> swqc-tmp/$SERIAL-part-count.txt
echo "Bios Version" >> swqc-tmp/parts-list.txt
echo "Bios version for TRUENAS-MINI-3.0-XL+ is showing as $BIOVER it should be  1.3V1" >> swqc-tmp/parts-list.txt
echo "Bios Version">> swqc-tmp/$SERIAL-diffme.txt
echo "Bios version is showing as $BIOVER it should be  1.3V1" >> swqc-tmp/$SERIAL-diffme.txt
echo "Bios Version" >> swqc-tmp/$SERIAL-PorF.txt
echo "fail" >> swqc-tmp/$SERIAL-PorF.txt
#
#
MINIXLPLUSBIOV=$(cat swqc-tmp/xlplussbios.txt)
#
#
#
fi
#
#
echo "===============================" >> swqc-tmp/$SERIAL-part-count.txt
echo "===============================" >> swqc-tmp/$SERIAL-part-count.txt
#
#
# BMC Firmware for TRUENAS-MINI-3.0-XL+ should be 3.60
#
if echo "$PRODUCT"| grep -Fwqi -e TRUENAS-MINI-3.0-XL+ && echo "$BMCINFO" | grep -oh "\w*3.60\w*"| grep -Fwqi -e 3.60; then
#
echo "BMC Firmware for TRUENAS-MINI-3.0-XL+" >> swqc-tmp/$SERIAL-part-count.txt
#
echo "BMC Firmware for TRUENAS-MINI-3.0-XL+ is correctly showing as 3.60"  >> swqc-tmp/swqc-output.txt
echo "BMC Firmware for TRUENAS-MINI-3.0-XL+ is correctly showing as 3.60"  > swqc-tmp/xlplussbmc.txt
echo "BMC Firmware for TRUENAS-MINI-3.0-XL+ is correctly showing as 3.60" >> swqc-tmp/$SERIAL-part-count.txt
echo "BMC Firmware" >> swqc-tmp/parts-list.txt
echo "BMC Firmware for TRUENAS-MINI-3.0-XL+ is correctly showing as 3.60" >> swqc-tmp/parts-list.txt
echo "BMC Firmware" >> swqc-tmp/$SERIAL-diffme.txt
echo "Correctly showing as 3.60" >> swqc-tmp/$SERIAL-diffme.txt
echo "BMC Firmware" >> swqc-tmp/$SERIAL-PorF.txt
echo "pass" >> swqc-tmp/$SERIAL-PorF.txt
#
elif echo "$PRODUCT"| grep -Fwqi -e TRUENAS-MINI-3.0-XL+ && echo "$BMCINFO" | grep -oh "\w*3.60\w*" != 3.60; then
#
echo "BMC Firmware for TRUENAS-MINI-3.0-XL+ is showing as $BMCINFO it should be  3.60" >> swqc-tmp/swqc-output.txt
echo "BMC Firmware for TRUENAS-MINI-3.0-XL+ is showing as $BMCINFO it should be  3.60" > swqc-tmp/xlplussbmc.txt
echo "BMC Firmware for TRUENAS-MINI-3.0-XL+ is showing as $BMCINFO it should be  3.60" >> swqc-tmp/warning.txt
echo "BMC Firmware for TRUENAS-MINI-3.0-XL+ is showing as $BMCINFO it should be  3.60" >> swqc-tmp/$SERIAL-part-count.txt
echo "BMC Firmware" >> swqc-tmp/parts-list.txt
echo "BMC Firmware for TRUENAS-MINI-3.0-XL+ is showing as $BMCINFO it should be  3.60" >> swqc-tmp/parts-list.txt
echo "BMC Firmware" >> swqc-tmp/$SERIAL-diffme.txt
echo "BMC Firmware is showing as $BMCINFO it should be  3.60" >> swqc-tmp/$SERIAL-diffme.txt
echo "BMC Firmware" >> swqc-tmp/$SERIAL-PorF.txt
echo "fail" >> swqc-tmp/$SERIAL-PorF.txt
#
#
MINIXLPLUSBIOV=$(cat swqc-tmp/xlplussbmc.txt)
#
#
#
fi
#
#
if echo "$PRODUCT"| grep -Fwqi -e TRUENAS-MINI-3.0-XL+ ; then 
echo "Memory count for TRUENAS-MINI-3.0-XL+"  >> swqc-tmp/swqc-output.txt
echo "Memory count for TRUENAS-MINI-3.0-XL+"  >> swqc-tmp/$SERIAL-part-count.txt
dmidecode -t memory | grep -i HMA82GR7AFR8N-UH | wc -l >> mini-xlplus-memory-count.txt
dmidecode -t memory | grep -i HMA82GR7AFR8N-UH | wc -l >> swqc-tmp/$SERIAL-part-count.txt
dmidecode -t memory | grep -i HMA82GR7AFR8N-UH | wc -l >> swqc-tmp/swqc-output.txt
echo "Memory Count" >> swqc-tmp/$SERIAL-diffme.txt
dmidecode -t memory | grep -i HMA82GR7AFR8N-UH | wc -l >> swqc-tmp/$SERIAL-diffme.txt
#
MINXPLUSMC=$(cat mini-xplus-memory-count.txt)
#
#
fi
#
#
#
if echo "$PRODUCT"| grep -Fwqi -e TRUENAS-MINI-3.0-XL+  && pciconf -lvcb | grep -oh "\w*T520\w*"| grep -Fwqi -e T520; then
echo "Add on nic card" >> swqc-tmp/swqc-output.txt
echo "Add on nic card" >> swqc-tmp/$SERIAL-diffme.txt
echo "Add on nic card" >> swqc-tmp/$SERIAL-part-count.txt
#
pciconf -lvcb | grep -i T520 | wc -l > swqc-tmp/10G-add-on-nic-count.txt
pciconf -lvcb | grep -i T520 > swqc-tmp/10G-add-on-nic-list.txt
pciconf -lvcb | grep -i T520 | wc -l  >> swqc-tmp/$SERIAL-part-count.txt
pciconf -lvcb | grep -i T520| wc -l  >> swqc-tmp/$SERIAL-diffme.txt
pciconf -lvcb | grep -i T520| wc -l >> swqc-tmp/swqc-output.txt
#
#
fi
#
#
#
#
#
#
echo "===============================" >> swqc-tmp/$SERIAL-part-count.txt
#
#
echo "point check H" >> swqc-tmp/swqc-output.txt
echo "point check H" > swqc-tmp/pointcheck-H.txt
#
#
#
#
#
echo "===============================" >> swqc-tmp/swqc-output.txt
#
#
#  TRUENAS-MINI-3.0-X+
#
#
#
if echo "$PRODUCT"| grep -Fwqi -e TRUENAS-MINI-3.0-X+; then
#
echo "TRUENAS-MINI-3.0-X+ fan info" >> swqc-tmp/swqc-output.txt
echo "Fan connectors 1(FAN1),2(FAN2),are NOT to be connected. "
echo "Fan connectors 1(FAN1),2(FAN2),are NOT to be connected. " >> swqc-tmp/swqc-output.txt
ipmitool sensor list | grep -i 'FAN[3A]' >> swqc-tmp/swqc-output.txt
ipmitool sensor list | grep -i 'FAN[3A]' >  swqc-tmp/xplusfan-output.txt
echo "FAN Thresholds" >> swqc-tmp/$SERIAL-part-count.txt
ipmitool sensor list | grep -i 'FAN[3A]' >> swqc-tmp/$SERIAL-part-count.txt
echo "FAN Thresholds" >> swqc-tmp/parts-list.txt
ipmitool sensor list | grep -i 'FAN[3A]' >> swqc-tmp/parts-list.txt
echo "FAN Thresholds" >> swqc-tmp/$SERIAL-diffme.txt
ipmitool sensor list | grep -i 'FAN[3A]'| cut -d "|" -f1 -f5 -f6 -f7 >> swqc-tmp/$SERIAL-diffme.txt
#
MINIXPLUSFAN=$(cat swqc-tmp/xplusfan-output.txt)
#
#
#
#
echo "FAN Thresholds" >> swqc-tmp/$SERIAL-diffme.txt
ipmitool sensor list | grep -i 'FAN[A12]'| cut -d "|" -f1 -f5 -f6 -f7  >> swqc-tmp/swqc-output.txt
ipmitool sensor list | grep -i 'FAN[A12]'| cut -d "|" -f1 -f5 -f6 -f7  >  swqc-tmp/xlplusfan-output.txt
ipmitool sensor list | grep -i 'FAN[A12]'| cut -d "|" -f1 -f5 -f6 -f7  >> swqc-tmp/$SERIAL-part-count.txt
ipmitool sensor list | grep -i 'FAN[A12]'| cut -d "|" -f1 -f5 -f6 -f7  >> swqc-tmp/parts-list.txt
ipmitool sensor list | grep -i 'FAN[A12]'| cut -d "|" -f1 -f5 -f6 -f7  >> swqc-tmp/$SERIAL-diffme.txt
#
XLPLUSFAN=$(cat swqc-tmp/xlplusfan-output.txt)
#
#
#
fi
#
#
#
#
#
# Bios for TRUENAS-MINI-3.0-X+ should be 1.3V1
#
if echo "$PRODUCT"| grep -Fwqi -e TRUENAS-MINI-3.0-X+ && echo "$BIOVER" | grep -oh "\w*1.3.V1\w*"| grep -Fwqi -e 1.3.V1; then
#
echo "Bios version for TRUENAS-MINI-3.0-X+ is correctly showing as 1.3V1"  >> swqc-tmp/swqc-output.txt
echo "Bios version for TRUENAS-MINI-3.0-X+ is correctly showing as 1.3V1"  > swqc-tmp/xplusbios.txt
echo "Bios Version" >> swqc-tmp/$SERIAL-part-count.txt
echo "Bios version for TRUENAS-MINI-3.0-X+ is correctly showing as 1.3V1" >> swqc-tmp/$SERIAL-part-count.txt
echo "Bios Version" >> swqc-tmp/parts-list.txt
echo "Bios version for TRUENAS-MINI-3.0-X+ is correctly showing as 1.3V1" >> swqc-tmp/parts-list.txt
echo "Bios Version" >> swqc-tmp/$SERIAL-diffme.txt
echo "Correctly showing as 1.3V1" >> swqc-tmp/$SERIAL-diffme.txt
echo "Bios Version" >> swqc-tmp/$SERIAL-PorF.txt
echo "pass" >> swqc-tmp/$SERIAL-PorF.txt
#
elif echo "$PRODUCT"| grep -Fwqi -e TRUENAS-MINI-3.0-X+ && echo "$BIOVER" | grep -oh "\w*1.3.V1\w*" != 1.3.V1; then
#
echo "Bios version for TRUENAS-MINI-3.0-X+ is showing as $BIOVER it should be  1.3V1" >> swqc-tmp/swqc-output.txt
echo "Bios version for TRUENAS-MINI-3.0-X+ is showing as $BIOVER it should be  1.3V1" > swqc-tmp/xplusbios.txt
echo "Bios version for TRUENAS-MINI-3.0-X+ is showing as $BIOVER it should be  1.3V1" >> swqc-tmp/warning.txt
echo "Bios Version" >> swqc-tmp/$SERIAL-part-count.txt
echo "Bios version for TRUENAS-MINI-3.0-X+ is showing as $BIOVER it should be  1.3V1" >> swqc-tmp/$SERIAL-part-count.txt
echo "Bios Verson" >> swqc-tmp/parts-list.txt
echo "Bios version for TRUENAS-MINI-3.0-X+ is showing as $BIOVER it should be  1.3V1" >> swqc-tmp/parts-list.txt
echo "Bios Verson" >> swqc-tmp/$SERIAL-diffme.txt
echo "Bios version is $BIOVER it should be  1.3V1" >> swqc-tmp/$SERIAL-diffme.txt
echo "Bios Version" >> swqc-tmp/$SERIAL-PorF.txt
echo "fail" >> swqc-tmp/$SERIAL-PorF.txt
#
#
MINIXPLUSBIOV=$(cat swqc-tmp/xplusbios.txt)
#
#
fi
#
#
# BMC Firmware for TRUENAS-MINI-3.0-X+ should be 3.60
#
#
#
if echo "$PRODUCT"| grep -Fwqi -e TRUENAS-MINI-3.0-X+ && echo "$BMCINFO" | grep -oh "\w*3.60\w*"| grep -Fwqi -e 3.60; then
echo "BMC firmware for TRUENAS-MINI-3.0-X+ is correctly showing as $BMCINFO it should be  3.60" >> swqc-tmp/swqc-output.txt
echo "BMC firmware for TRUENAS-MINI-3.0-X+ is correctly showing as $BMCINFO it should be  3.60" > swqc-tmp/xplusbmc.txt
echo "BMC Firmware" >> swqc-tmp/$SERIAL-part-count.txt
echo "BMC firmware for TRUENAS-MINI-3.0-X+ is correctly showing as $BMCINFO it should be  3.60" >> swqc-tmp/$SERIAL-part-count.txt
echo "BMC Firmware" >> swqc-tmp/parts-list.txt
echo "BMC firmware for TRUENAS-MINI-3.0-X+ is correctly showing as $BMCINFO it should be  3.60" >> swqc-tmp/parts-list.txt
echo "BMC Firmware" >> swqc-tmp/$SERIAL-diffme.txt
echo "Correctly showing as 3.60" >> swqc-tmp/$SERIAL-diffme.txt
echo "BMC Firmware" >> swqc-tmp/$SERIAL-PorF.txt
echo "pass" >> swqc-tmp/$SERIAL-PorF.txt
#
#
elif echo "$PRODUCT"| grep -Fwqi -e TRUENAS-MINI-3.0-X+ && echo "$$BMCINFO" | grep -oh "\w*3.60\w*" != 3.60; then
#
echo "BMC firmware for TRUENAS-MINI-3.0-X+ is showing as $BMCINFO it should be  3.60" >> swqc-tmp/swqc-output.txt
echo "BMC firmware for TRUENAS-MINI-3.0-X+ is showing as $BMCINFO it should be  3.60" > swqc-tmp/xplusbmc.txt
echo "BMC firmware for TRUENAS-MINI-3.0-X+ is showing as $BMCINFO it should be  3.60" >> swqc-tmp/warning.txt
echo "BMC Firmware" >> swqc-tmp/$SERIAL-part-count.txt
echo "BMC firmware for TRUENAS-MINI-3.0-X+ is showing as $BMCINFO it should be  3.60" >> swqc-tmp/$SERIAL-part-count.txt
echo "BMC Firmware" >> swqc-tmp/parts-list.txt
echo "BMC firmware for TRUENAS-MINI-3.0-X+ is showing as $BMCINFO it should be  3.60" >> swqc-tmp/parts-list.txt
echo "BMC Firmware" >> swqc-tmp/$SERIAL-diffme.txt
echo "BMC firmware is $BMCINFO it should be  3.60" >> swqc-tmp/$SERIAL-diffme.txt
echo "BMC Firmware" >> swqc-tmp/$SERIAL-PorF.txt
echo "fail" >> swqc-tmp/$SERIAL-PorF.txt                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    
#
#
MINIPLUSBMC=$(cat swqc-tmp/xplusbmc.txt)
#
#
fi
#
if echo "$PRODUCT"| grep -Fwqi -e TRUENAS-MINI-3.0-X+; then 
echo "Memory count for TRUENAS-MINI-3.0-X+"  >> swqc-tmp/swqc-output.txt
echo "Memory count for TRUENAS-MINI-3.0-X+"  >> swqc-tmp/$SERIAL-part-count.txt
dmidecode -t memory | grep -i HMA82GR7AFR8N-UH | wc -l >> mini-xplus-memory-count.txt
dmidecode -t memory | grep -i HMA82GR7AFR8N-UH>> mini-xplus-memory-list.txt
dmidecode -t memory | grep -i HMA82GR7AFR8N-UH | wc -l >> swqc-tmp/$SERIAL-part-count.txt
dmidecode -t memory | grep -i HMA82GR7AFR8N-UH | wc -l >> swqc-tmp/swqc-output.txt
echo "Memory Count" >> swqc-tmp/$SERIAL-diffme.txt
dmidecode -t memory | grep -i HMA82GR7AFR8N-UH | wc -l >> swqc-tmp/$SERIAL-diffme.txt
#
MINXPLUSMC=$(cat mini-xplus-memory-count.txt)
#
#
fi
#
#
#
#
#
#
if echo "$PRODUCT"| grep -Fwqi -e TRUENAS-MINI-3.0-X+  && pciconf -lvcb | grep -oh "\w*T520\w*"| grep -Fwqi -e T520; then
echo "Add on nic card" >> swqc-tmp/swqc-output.txt
echo "Add on nic card" >> swqc-tmp/$SERIAL-diffme.txt
echo "Add on nic card" >> swqc-tmp/$SERIAL-part-count.txt
#
pciconf -lvcb | grep -i T520 | wc -l > swqc-tmp/10G-add-on-nic-count.txt
pciconf -lvcb | grep -i T520 > swqc-tmp/10G-add-on-nic-list.txt
pciconf -lvcb | grep -i T520 | wc -l  >> swqc-tmp/$SERIAL-part-count.txt
pciconf -lvcb | grep -i T520| wc -l  >> swqc-tmp/$SERIAL-diffme.txt
pciconf -lvcb | grep -i T520| wc -l >> swqc-tmp/swqc-output.txt
#
#
fi
#
#
#
#
#
#
#
echo "===============================" >> swqc-tmp/swqc-output.txt
echo "===============================" >> swqc-tmp/$SERIAL-part-count.txt
echo "===============================" >> swqc-tmp/$SERIAL-part-count.txt
#
#
echo "point check I" >> swqc-tmp/swqc-output.txt
echo "point check I" > swqc-tmp/pointcheck-I.txt
#
# TRUENAS-R10-Version 1.0
#
# 
#
#
if echo "$PRODUCT"| grep -Fwqi -e TRUENAS-R10 ; then
#
echo "TrueNAS R10 1.0 fan info" >> swqc-tmp/swqc-output.txt
echo "Fan connectors 1(FAN1),5(FAN5), and 8(FANC) are NOT to be connected. "
echo "Fan connectors 1(FAN1),5(FAN5), and 8(FANC) are NOT to be connected. " >> swqc-tmp/swqc-output.txt
ipmitool sensor list | grep -i 'FAN[234AB]' >> swqc-tmp/swqc-output.txt
ipmitool sensor list | grep -i 'FAN[234AB]' >  swqc-tmp/r10fan-output.txt
#
R10AFAN=$( cat swqc-tmp/r10fan-output.txt)
#
#
ipmitool sdr list | grep -i 'FAN[234AB]' > swqc-tmp/r10-sdrout.txt
ipmitool sdr list | grep -i 'FAN[234AB]' >> swqc-tmp/swqc-output.txt
#
#
R10SDR=$( cat swqc-tmp/r10-sdrout.txt)
#
fi
#
#
echo "===============================" >> swqc-tmp/swqc-output.txt
#
#
# TrueNAS R20 IX-TN-R20A-S-V.02
#
#
#
#
#
if echo "$PRODUCT"| grep -Fwqi -e TRUENAS-R20A ; then
#
echo "TrueNAS R20 IX-TN-R20A-S-V.02 fan info" >> swqc-tmp/swqc-output.txt
echo "Fan connectors 5(FAN5), 6(FANA),7(FANB), and 8(FANC) are NOT to be connected. "
echo "Fan connectors 5(FAN5), 6(FANA),7(FANB), and 8(FANC) are NOTto be connected. " >> swqc-tmp/swqc-output.txt
ipmitool sensor list | grep -i 'FAN[5ABC]' >> swqc-tmp/swqc-output.txt
ipmitool sensor list | grep -i 'FAN[5ABC]' >  swqc-tmp/r20afan-output.txt
#
R20AFAN=$( cat swqc-tmp/r20afan-output.txt)
#
#
#
fi
#
#
#
# TrueNAS R20 IX-TN-R20
#
#
#
if echo "$PRODUCT"|grep -Fwqi -e TRUENAS-R20 ; then
#
echo "TrueNAS R20 IX-TN-R20 Fan Info "  >> swqc-tmp/swqc-output.txt
echo "Fan connectors 5(FAN5), and 8(FANC) are NOT be connected. "
echo "Fan connectors 5(FAN5), 8(FANC) are NOT be connected. " >> swqc-tmp/swqc-output.txt
ipmitool sensor list | grep -i 'FAN[AB234]' >> swqc-tmp/swqc-output.txt
ipmitool sensor list | grep -i 'FAN[AB234]' >  swqc-tmp/r20fan-output.txt
#
R20FAN=$( cat swqc-tmp/r20fan-output.txt)
#
#
#
ipmitool sdr list | grep -i 'FAN[AB234]' > swqc-tmp/r20-sdrout.txt
ipmitool sdr list | grep -i 'FAN[AB234]' >> swqc-tmp/swqc-output.txt
#
#
#
R20SDR=$( cat swqc-tmp/r20-sdrout.txt)
#
fi
#
if echo "$R20SDR" | grep -Fwqi  -e "no reading" ; then 
#
#
echo "The following FAN(s) show no reading" > swqc-tmp/r20-fan-errors.txt
echo "The following FAN(s) show no reading" >> swqc-tmp/swqc-output.txt
cat swqc-tmp/r20-sdrout.txt | grep -i "no reading" >> swqc-tmp/swqc-output.txt
cat swqc-tmp/r20-sdrout.txt | grep -i "no reading" >> swqc-tmp/r20-fan-errors.txt
#
R20FAN-ERRORS=$(cat swqc-tmp/r20-fan-errors.txt)
#
fi
#
#
################################################################
#
echo "===============================" >> swqc-tmp/swqc-output.txt
#
if echo "$PRODUCT"|grep -Fwqi -e TRUENAS-R40; then
#
echo "TrueNAS R40 Specific valadation" >> swqc-tmp/swqc-output.txt
#
#
fi
#
#
# Bios for TRUENAS-R40 should be 3.6v6
#
if echo "$PRODUCT"| grep -Fwqi -e 'Product Name: TRUENAS-R40' && echo "$BIOVER" | grep -oh "\w*3.3\w*"| grep -Fwqi -e 3.3; then
#
echo "Bios verison" >> swqc-tmp/$SERIAL-part-count.txt
echo "Bios verison" >> swqc-tmp/$SERIAL-diffme.txt
echo "Bios version for TRUENAS-R40 is correctly showing as  3.3"  >> swqc-tmp/swqc-output.txt
echo "Bios version for TRUENAS-R40 is correctly showing as  3.3"  > swqc-tmp/R40-bios.txt
echo "Bios version for TRUENAS-R40 is correctly showing as  3.3"  >> swqc-tmp/$SERIAL-part-count.txt
echo "Bios version for TRUENAS-R40 is correctly showing as  3.3"  >> swqc-tmp/$SERIAL-diffme.txt
echo "Bios Version" >> swqc-tmp/$SERIAL-PorF.txt  
echo "pass" >> swqc-tmp/$SERIAL-PorF.txt  
#
#
elif echo "$PRODUCT"| grep -Fwqi -e 'Product Name: TRUENAS-R40' && echo "$BIOVER"| grep -oh "\w*3.6v6\w*" != 3.6v6; then
echo "Bios verison" >> swqc-tmp/$SERIAL-part-count.txt
echo "Bios verison" >> swqc-tmp/$SERIAL-diffme.txt
echo "Bios version for TRUENAS-R40 is showing as $BIOVER it should be  3.3" >> swqc-tmp/swqc-output.txt
echo "Bios version for TRUENAS-R40 is showing as $BIOVER it should be  3.3" > swqc-tmp/R40-bios.txt
echo "Bios version for TRUENAS-R40 is showing as $BIOVER it should be  3.3" >> swqc-tmp/warning.txt
echo "Bios version for TRUENAS-R40 is showing as $BIOVER it should be  3.3" >> swqc-tmp/$SERIAL-part-count.txt
echo "Bios version for TRUENAS-R40 is showing as $BIOVER it should be  3.3" >> swqc-tmp/$SERIAL-diffme.txt
echo "Bios Version" >> swqc-tmp/$SERIAL-PorF.txt  
echo "fail" >> swqc-tmp/$SERIAL-PorF.txt 
#
#
R40IOV=$(cat swqc-tmp/R40-bios.txt)
#
#
fi
#
#
if echo "$PRODUCT"| grep -Fwqi -e 'Product Name: TRUENAS-R40' && echo "$BMCINFO" | grep -oh "\w*1.71\w*"| grep -Fwqi -e 1.71; then
echo "BMC Firmware" >> swqc-tmp/$SERIAL-part-count.txt
echo "BMC Firmware" >> swqc-tmp/$SERIAL-diffme.txt
echo "BMC firmware for TRUENAS-R40 is correctly showing as $BMCINFO it should be  1.71.11" >> swqc-tmp/swqc-output.txt
echo "BMC firmware for TRUENAS-R40 is correctly showing as $BMCINFO it should be  1.71.11" >> swqc-tmp/$SERIAL-part-count.txt
echo "BMC firmware for TRUENAS-R40 is correctly showing as $BMCINFO it should be  1.71.11" >> swqc-tmp/$SERIAL-diffme.txt
echo "BMC firmware for TRUENAS-R40 is correctly showing as $BMCINFO it should be  1.71.11" >> swqc-tmp/swqc-output.txt
echo "BMC firmware for TRUENAS-R40 is correctly showing as $BMCINFO it should be  1.71.11" > swqc-tmp/R40-bmc.txt
echo "BMC firmware" >> swqc-tmp/$SERIAL-PorF.txt  
echo "pass" >> swqc-tmp/$SERIAL-PorF.txt 
#
#
elif echo "$PRODUCT"| grep -Ewqi 'Product Name: TRUENAS-R40' && echo "$BMCINFO" | grep -oh "\w*1.71\w*" != 1.71; then
echo "BMC Firmware" >> swqc-tmp/$SERIAL-part-count.txt
echo "BMC Firmware" >> swqc-tmp/$SERIAL-diffme.txt
echo "BMC Firmware for TRUENAS-R40 is showing as $BMCINFO it should be  1.71.11" >> swqc-tmp/swqc-output.txt
echo "BMC Firmware for TRUENAS-R40 is showing as $BMCINFO it should be  1.71.11" > swqc-tmp/R40-bmc.txt
echo "BMC Firmware for TRUENAS-R40 is showing as $BMCINFO it should be  1.71.11" >> swqc-tmp/warning.txt
echo "BMC firmware" >> swqc-tmp/$SERIAL-PorF.txt  
echo "fail" >> swqc-tmp/$SERIAL-PorF.txt 
#
#
#
R40BMC=$(cat swqc-tmp/R40-bmc.txt)
#
#
fi
#
#
if echo "$PRODUCT"| grep -Fwqi -e 'Product Name: TRUENAS-R40'; then
#
echo "R40 Memory Count" >> swqc-tmp/$SERIAL-part-count.txt
echo "R40 Memory Count" >> swqc-tmp/$SERIAL-diffme.txt
#
#
dmidecode -t memory |grep Part|grep M393A2K40BB1-CRC | wc -l >> swqc-tmp/$SERIAL-part-count.txt
dmidecode -t memory |grep Part|grep M393A2K40BB1-CRC | wc -l >> swqc-tmp/$SERIAL-diffme.txt
#
#
#
fi 
#
#
if echo "$PRODUCT"| grep -Fwqi -e TRUENAS-R40; then
#
echo " Verifying Fan speed is set to Standard for R40 " > swqc-tmp/swqc-output.txt
#
# Run the following command to make sure fan speed is set to 00 standard:
# It should return 01
# The values are:
# Standard: 0
# Full: 1
# Optimal: 2
# Heavy IO: 4
#
ipmitool raw 0x30 0x45 0x00 >> swqc-tmp/swqc-output.txt
ipmitool raw 0x30 0x45 0x00 > swqc-tmp/R40fanspeed.txt
#
R40FANSPEED=$(cat swqc-tmp/R40fanspeed.txt)
#
#
fi
#
#
if echo "$PRODUCT"| grep -Fwqi -e 'Product Name: TRUENAS-R40' && echo "$R40FANSPEED" | grep -oh "\w*00\w*"| grep -Fwqi -e 00; then
#
echo "Fan speed" >> swqc-tmp/swqc-output.txt
echo "Fan speed" >> swqc-tmp/$SERIAL-part-count.txt
echo "Fan speed" >> swqc-tmp/$SERIAL-diffme.txt
#
echo "TRUENAS-R40 fan speed is correctly set to Standard Speed 00"  >> swqc-tmp/swqc-output.txt
echo "TRUENAS-R40 fan speed is correctly set to Standard Speed 00"  > swqc-tmp/R40-fans.txt
echo "Standard Speed 00"  >> swqc-tmp/$SERIAL-diffme.txt
echo "TRUENAS-R40 fan speed is correctly set to Standard Speed 00"  >> swqc-tmp/$SERIAL-part-count.txt
#
elif echo "$PRODUCT"| grep -Ewqi 'Product Name: TRUENAS-R40' && echo "$R40FANSPEED" | grep -oh "\w*04\w*" != 04; then
#
echo "Fan speed" >> swqc-tmp/swqc-output.txt
echo "Fan speed" >> swqc-tmp/$SERIAL-part-count.txt
echo "Fan speed" >> swqc-tmp/$SERIAL-diffme.txt
#
echo "TRUENAS-R40 fan speed is showing as $R40FANSPEED it should be  Standard Speed 00" >> swqc-tmp/swqc-output.txt
echo "TRUENAS-R40 fan speed is showing as $R40FANSPEED it should be  Standard Speed 00" > swqc-tmp/R40-fans.txt
echo "TRUENAS-R40 fan speed is showing as $R40FANSPEED it should be  Standard Speed 00" >> swqc-tmp/warning.txt
echo "TRUENAS-R40 fan speed is correctly set to Standard Speed 00" >> swqc-tmp/$SERIAL-part-count.txt
echo "Incorrect FAN Speed showing as $R40FANSPEED it should be Standard Speed 00"  >> swqc-tmp/$SERIAL-diffme.txt
#
#
R40FS=$(cat swqc-tmp/R40-fans.txt)
#
#
fi
#
#
if echo "$PRODUCT"| grep -Fwqi -e TRUENAS-R40; then
#
echo " FAN Check"  >> swqc-tmp/$SERIAL-diffme.txt
ipmitool sdr list | grep -i 'FAN[AB2345]' | cut -d\| -f1 -f3 >> swqc-tmp/$SERIAL-diffme.txt
#
#
fi
#
#
#
#
if echo "$PRODUCT"|grep -Fwqi -e TRUENAS-R40  && pciconf -lvcb | grep -oh "\w*T62100-LP-CR\w*"| grep -Fwqi -e T62100-LP-CR; then
echo "Add on nic card" >> swqc-tmp/swqc-output.txt
echo "Add on nic card" >> swqc-tmp/$SERIAL-diffme.txt
echo "Add on nic card" >> swqc-tmp/$SERIAL-part-count.txt
#
pciconf -lvcb | grep -i T62100-LP-CR | wc -l > swqc-tmp/R40-add-on-nic-count.txt
pciconf -lvcb | grep -i T62100-LP-CR | wc -l  >> swqc-tmp/$SERIAL-part-count.txt
pciconf -lvcb | grep -i T62100-LP-CR| wc -l  >> swqc-tmp/$SERIAL-diffme.txt
pciconf -lvcb | grep -i T62100-LP-CR| wc -l >> swqc-tmp/swqc-output.txt
#
#
fi
#
#
#
#
if echo "$PRODUCT"|grep -Fwqi -e TRUENAS-R40  && pciconf -lvcb | grep -oh "\w*X710\w*"| grep -Fwqi -e X710; then
echo "Add on nic card" >> swqc-tmp/swqc-output.txt
echo "Add on nic card" >> swqc-tmp/$SERIAL-diffme.txt
echo "Add on nic card" >> swqc-tmp/$SERIAL-part-count.txt
#
pciconf -lvcb | grep -i X710 | wc -l > swqc-tmp/R40-add-on-nic-count.txt
pciconf -lvcb | grep -i X710 > swqc-tmp/R40-add-on-nic-list.txt
pciconf -lvcb | grep -i X710 | wc -l  >> swqc-tmp/$SERIAL-part-count.txt
pciconf -lvcb | grep -i X710 | wc -l  >> swqc-tmp/$SERIAL-diffme.txt
pciconf -lvcb | grep -i X710 | wc -l >> swqc-tmp/swqc-output.txt
#
#
fi
#
#
#
#
#
#
if echo "$PRODUCT"|grep -Fwqi -e TRUENAS-R40  && ifconfig -va | grep -oh "\w*SFP-10GSR-85\w*"| grep -Fwqi -e SFP-10GSR-85; then
echo "10G SFP Count" >> swqc-tmp/swqc-output.txt
echo "10G SFP Count" >> swqc-tmp/$SERIAL-diffme.txt
echo "10G SFP Count" >> swqc-tmp/$SERIAL-part-count.txt
#
ifconfig -va | grep -i SFP-10GSR-85| wc -l > swqc-tmp/R40-10G-SFP-count.txt
ifconfig -va | grep -i SFP-10GSR-85 > swqc-tmp/R40-10G-SFP-list.txt
ifconfig -va | grep -i SFP-10GSR-85 | wc -l  >> swqc-tmp/$SERIAL-part-count.txt
ifconfig -va | grep -i SFP-10GSR-85 | wc -l >> swqc-tmp/$SERIAL-diffme.txt
ifconfig -va | grep -i SFP-10GSR-85 | wc -l >> swqc-tmp/swqc-output.txt
#
#
fi
#
#
#
if echo "$PRODUCT"|grep -Fwqi -e TRUENAS-R40  && ifconfig -va | grep -oh "\w*SM10G-SR\w*"| grep -Fwqi -e SM10G-SR; then
echo "10G SFP Count" >> swqc-tmp/swqc-output.txt
echo "10G SFP Count" >> swqc-tmp/$SERIAL-diffme.txt
echo "10G SFP Count" >> swqc-tmp/$SERIAL-part-count.txt
#
ifconfig -va | grep -i SM10G-SR| wc -l > swqc-tmp/R40-10G-SFP-count.txt
ifconfig -va | grep -i SM10G-SR > swqc-tmp/R40-10G-SFP-list.txt
ifconfig -va | grep -i SM10G-SR | wc -l  >> swqc-tmp/$SERIAL-part-count.txt
ifconfig -va | grep -i SM10G-SR | wc -l >> swqc-tmp/$SERIAL-diffme.txt
ifconfig -va | grep -i SM10G-SR | wc -l >> swqc-tmp/swqc-output.txt
#
#
fi
#
#
#
if echo "$PRODUCT"|grep -Fwqi -e TRUENAS-R40  && ifconfig -va | grep -oh "\w*25GBASE-SR\w*"| grep -Fwqi -e 25GBASE-SR; then
echo "25G SFP Count" >> swqc-tmp/swqc-output.txt
echo "25G SFP Count" >> swqc-tmp/$SERIAL-diffme.txt
echo "25G SFP Count" >> swqc-tmp/$SERIAL-part-count.txt
#
ifconfig -va | grep -i 25GBASE-SR| wc -l > swqc-tmp/R40-25G-SFP-count.txt
ifconfig -va | grep -i 25GBASE-SR > swqc-tmp/R40-25G-SFP-list.txt
ifconfig -va | grep -i 25GBASE-SR | wc -l  >> swqc-tmp/$SERIAL-part-count.txt
ifconfig -va | grep -i 25GBASE-SR | wc -l >> swqc-tmp/$SERIAL-diffme.txt
ifconfig -va | grep -i 25GBASE-SR | wc -l >> swqc-tmp/swqc-output.txt
#
#
fi
#
#
#
if echo "$PRODUCT"|grep -Fwqi -e TRUENAS-R40  && ifconfig -va | grep -oh "\w*QSFP-SR4-40G\w*"| grep -Fwqi -e QSFP-SR4-40G; then
echo "40G SFP Count" >> swqc-tmp/swqc-output.txt
echo "40G SFP Count" >> swqc-tmp/$SERIAL-diffme.txt
echo "40G SFP Count" >> swqc-tmp/$SERIAL-part-count.txt
#
ifconfig -va | grep -i QSFP-SR4-40G | wc -l > swqc-tmp/R40-40G-SFP-count.txt
ifconfig -va | grep -i QSFP-SR4-40G > swqc-tmp/R40-40G-SFP-list.txt
ifconfig -va | grep -i QSFP-SR4-40G | wc -l  >> swqc-tmp/$SERIAL-part-count.txt
ifconfig -va | grep -i QSFP-SR4-40G | wc -l >> swqc-tmp/$SERIAL-diffme.txt
ifconfig -va | grep -i QSFP-SR4-40G | wc -l >> swqc-tmp/swqc-output.txt
#
#
fi
#
#
#
#
#
echo "===============================" >> swqc-tmp/swqc-output.txt
#
################################################################
#
#
echo "===============================" >> swqc-tmp/swqc-output.txt
#
if echo "$PRODUCT"|grep -Fwqi -e TRUENAS-R20B; then
#
echo "TrueNAS R20B Specific valadation" >> swqc-tmp/swqc-output.txt
#
#
fi
#
#
# Bios for TRUENAS-R20B should be 3.6v6
#
if echo "$PRODUCT"| grep -Fwqi -e 'Product Name: TRUENAS-R20B' && echo "$BIOVER" | grep -oh "\w*3.3.V6\w*"| grep -Fwqi -e 3.3.V6; then
#
echo "Bios verison" >> swqc-tmp/$SERIAL-part-count.txt
echo "Bios verison" >> swqc-tmp/$SERIAL-diffme.txt
echo "Bios version for TRUENAS-R20B is correctly showing as  3.3.V6"  >> swqc-tmp/swqc-output.txt
echo "Bios version for TRUENAS-R20B is correctly showing as  3.3.V6"  > swqc-tmp/R20B-bios.txt
echo "Bios version for TRUENAS-R20B is correctly showing as  3.3.V6"  >> swqc-tmp/$SERIAL-part-count.txt
echo "Bios version for TRUENAS-R20B is correctly showing as  3.3.V6"  >> swqc-tmp/$SERIAL-diffme.txt
echo "Bios Version" >> swqc-tmp/$SERIAL-PorF.txt  
echo "pass" >> swqc-tmp/$SERIAL-PorF.txt
#
#
elif echo "$PRODUCT"| grep -Fwqi -e 'Product Name: TRUENAS-R20B' && echo "$BIOVER"| grep -oh "\w*3.6v6\w*" != 3.6v6; then
echo "Bios verison" >> swqc-tmp/$SERIAL-part-count.txt
echo "Bios verison" >> swqc-tmp/$SERIAL-diffme.txt
echo "Bios version for TRUENAS-R20B is showing as $BIOVER it should be  3.3.V6" >> swqc-tmp/swqc-output.txt
echo "Bios version for TRUENAS-R20B is showing as $BIOVER it should be  3.3.V6" > swqc-tmp/R20B-bios.txt
echo "Bios version for TRUENAS-R20B is showing as $BIOVER it should be  3.3.V6" >> swqc-tmp/warning.txt
echo "Bios version for TRUENAS-R20B is showing as $BIOVER it should be  3.3.V6" >> swqc-tmp/$SERIAL-part-count.txt
echo "Bios version for TRUENAS-R20B is showing as $BIOVER it should be  3.3.V6" >> swqc-tmp/$SERIAL-diffme.txt
echo "Bios Version" >> swqc-tmp/$SERIAL-PorF.txt  
echo "fail" >> swqc-tmp/$SERIAL-PorF.tx
#
#
R20BIOV=$(cat swqc-tmp/R20B-bios.txt)
#
#
fi
#
#
if echo "$PRODUCT"| grep -Fwqi -e 'Product Name: TRUENAS-R20B' && echo "$BMCINFO" | grep -oh "\w*1.71\w*"| grep -Fwqi -e 1.71; then
echo "BMC Firmware" >> swqc-tmp/$SERIAL-part-count.txt
echo "BMC Firmware" >> swqc-tmp/$SERIAL-diffme.txt
echo "BMC firmware for TRUENAS-R20B is correctly showing as $BMCINFO it should be  1.71.11" >> swqc-tmp/swqc-output.txt
echo "BMC firmware for TRUENAS-R20B is correctly showing as $BMCINFO it should be  1.71.11" >> swqc-tmp/$SERIAL-part-count.txt
echo "BMC firmware for TRUENAS-R20B is correctly showing as $BMCINFO it should be  1.71.11" >> swqc-tmp/$SERIAL-diffme.txt
#
echo "BMC firmware for TRUENAS-R20B is correctly showing as $BMCINFO it should be  1.71.11" >> swqc-tmp/swqc-output.txt
echo "BMC firmware for TRUENAS-R20B is correctly showing as $BMCINFO it should be  1.71.11" > swqc-tmp/R20B-bmc.txt
#
elif echo "$PRODUCT"| grep -Ewqi 'Product Name: TRUENAS-R20B' && echo "$BMCINFO" | grep -oh "\w*1.71.11\w*" != 1.71.11; then
echo "BMC Firmware" >> swqc-tmp/$SERIAL-part-count.txt
echo "BMC Firmware" >> swqc-tmp/$SERIAL-diffme.txt
echo "Bios version for TRUENAS-R20B is showing as $BMCINFO it should be  1.71.11" >> swqc-tmp/swqc-output.txt
echo "Bios version for TRUENAS-R20B is showing as $BMCINFO it should be  1.71.11" > swqc-tmp/R20B-bmc.txt
echo "Bios version for TRUENAS-R20B is showing as $BMCINFO it should be  1.71.11" >> swqc-tmp/warning.txt
#
#
#
R20BBMC=$(cat swqc-tmp/R20B-bmc.txt)
#
#
fi
#
#
if echo "$PRODUCT"| grep -Fwqi -e 'Product Name: TRUENAS-R20B'; then
#
echo "R20B Memory Count" >> swqc-tmp/$SERIAL-part-count.txt
echo "R20B Memory Count" >> swqc-tmp/$SERIAL-diffme.txt
#
#
dmidecode -t memory |grep Part|grep M393A2K40BB1-CRC | wc -l >> swqc-tmp/$SERIAL-part-count.txt
dmidecode -t memory |grep Part|grep M393A2K40BB1-CRC | wc -l >> swqc-tmp/$SERIAL-diffme.txt
#
#
#
fi 
#
#
if echo "$PRODUCT"| grep -Fwqi -e TRUENAS-R20B; then
#
echo " Verifying Fan speed is set to FULL for R20B " > swqc-tmp/swqc-output.txt
#
# Run the following command to make sure fan speed is set to  04:
# It should return 01
# The values are:
# Standard: 0
# Full: 1
# Optimal: 2
# Heavy IO: 4
#
ipmitool raw 0x30 0x45 0x00 >> swqc-tmp/swqc-output.txt
ipmitool raw 0x30 0x45 0x00 > swqc-tmp/R20Bfanspeed.txt
#
R20BFANSPEED=$(cat swqc-tmp/R20Bfanspeed.txt)
#
#
fi
#
#
if echo "$PRODUCT"| grep -Fwqi -e 'Product Name: TRUENAS-R20B' && echo "$R20BFANSPEED" | grep -oh "\w*04\w*"| grep -Fwqi -e 04; then
#
echo "Fan speed" >> swqc-tmp/swqc-output.txt
echo "Fan speed" >> swqc-tmp/$SERIAL-part-count.txt
echo "Fan speed" >> swqc-tmp/$SERIAL-diffme.txt
#
echo "TRUENAS-R20B fan speed is correctly set to Heavy IO Speed 04"  >> swqc-tmp/swqc-output.txt
echo "TRUENAS-R20B fan speed is correctly set to Heavy IO Speed 04"  > swqc-tmp/R20B-fans.txt
echo "Heavy IO Speed 04"  >> swqc-tmp/$SERIAL-diffme.txt
echo "TRUENAS-R20B fan speed is correctly set to Heavy IO Speed 04"  >> swqc-tmp/$SERIAL-part-count.txt
#
elif echo "$PRODUCT"| grep -Ewqi 'Product Name: TRUENAS-R20B' && echo "$R20BFANSPEED" | grep -oh "\w*04\w*" != 04; then
#
echo "Fan speed" >> swqc-tmp/swqc-output.txt
echo "Fan speed" >> swqc-tmp/$SERIAL-part-count.txt
echo "Fan speed" >> swqc-tmp/$SERIAL-diffme.txt
#
echo "TRUENAS-R20B fan speed is showing as $R20BFANSPEED it should be  04  Heavy IO Speed" >> swqc-tmp/swqc-output.txt
echo "TRUENAS-R20B fan speed is showing as $R20BFANSPEED it should be  04  Heavy IO Speed" > swqc-tmp/R20B-fans.txt
echo "TRUENAS-R20B fan speed is showing as $R20BFANSPEED it should be  04  Heavy IO Speed" >> swqc-tmp/warning.txt
echo "TRUENAS-R20B fan speed is correctly set to Heavy IO Speed 04" >> swqc-tmp/$SERIAL-part-count.txt
echo "Incorrect FAN Speed showing as $R20BFANSPEED it should be 04 Heavy IO Speed"  >> swqc-tmp/$SERIAL-diffme.txt
#
#
R20BFS=$(cat swqc-tmp/R20B-fans.txt)
#
#
fi
#
#
if echo "$PRODUCT"| grep -Fwqi -e TRUENAS-R20B; then
#
echo " FAN Check"  >> swqc-tmp/$SERIAL-diffme.txt
ipmitool sdr list | grep -i 'FAN[AB2345]' | cut -d\| -f1 -f3 >> swqc-tmp/$SERIAL-diffme.txt
#
#
fi
#
#
#
#
if echo "$PRODUCT"|grep -Fwqi -e TRUENAS-R20B  && pciconf -lvcb | grep -oh "\w*T62100-LP-CR\w*"| grep -Fwqi -e T62100-LP-CR; then
echo "Add on nic card" >> swqc-tmp/swqc-output.txt
echo "Add on nic card" >> swqc-tmp/$SERIAL-diffme.txt
echo "Add on nic card" >> swqc-tmp/$SERIAL-part-count.txt
#
pciconf -lvcb | grep -i T62100-LP-CR | wc -l > swqc-tmp/R20B-add-on-nic-count.txt
pciconf -lvcb | grep -i T62100-LP-CR | wc -l  >> swqc-tmp/$SERIAL-part-count.txt
pciconf -lvcb | grep -i T62100-LP-CR| wc -l  >> swqc-tmp/$SERIAL-diffme.txt
pciconf -lvcb | grep -i T62100-LP-CR| wc -l >> swqc-tmp/swqc-output.txt
#
#
fi
#
#
#
#
if echo "$PRODUCT"|grep -Fwqi -e TRUENAS-R20B  && pciconf -lvcb | grep -oh "\w*X710\w*"| grep -Fwqi -e X710; then
echo "Add on nic card" >> swqc-tmp/swqc-output.txt
echo "Add on nic card" >> swqc-tmp/$SERIAL-diffme.txt
echo "Add on nic card" >> swqc-tmp/$SERIAL-part-count.txt
#
pciconf -lvcb | grep -i X710 | wc -l > swqc-tmp/R20B-add-on-nic-count.txt
pciconf -lvcb | grep -i X710 > swqc-tmp/R20B-add-on-nic-list.txt
pciconf -lvcb | grep -i X710 | wc -l  >> swqc-tmp/$SERIAL-part-count.txt
pciconf -lvcb | grep -i X710 | wc -l  >> swqc-tmp/$SERIAL-diffme.txt
pciconf -lvcb | grep -i X710 | wc -l >> swqc-tmp/swqc-output.txt
#
#
fi
#
#
#
#
if echo "$PRODUCT"|grep -Fwqi -e TRUENAS-R20B  && pciconf -lvcb | grep -oh "\w*T520\w*"| grep -Fwqi -e T520; then
echo "Add on nic card" >> swqc-tmp/swqc-output.txt
echo "Add on nic card" >> swqc-tmp/$SERIAL-diffme.txt
echo "Add on nic card" >> swqc-tmp/$SERIAL-part-count.txt
#
pciconf -lvcb | grep -i T520 | wc -l > swqc-tmp/R20B-add-on-nic-count.txt
pciconf -lvcb | grep -i T520 > swqc-tmp/R20B-add-on-nic-list.txt
pciconf -lvcb | grep -i T520 | wc -l  >> swqc-tmp/$SERIAL-part-count.txt
pciconf -lvcb | grep -i T520 | wc -l  >> swqc-tmp/$SERIAL-diffme.txt
pciconf -lvcb | grep -i T520 | wc -l >> swqc-tmp/swqc-output.txt
#
#
fi
#
#
#
#
if echo "$PRODUCT"|grep -Fwqi -e TRUENAS-R20B  && ifconfig -va | grep -oh "\w*SFP-10GSR-85\w*"| grep -Fwqi -e SFP-10GSR-85; then
echo "10G SFP Count" >> swqc-tmp/swqc-output.txt
echo "10G SFP Count" >> swqc-tmp/$SERIAL-diffme.txt
echo "10G SFP Count" >> swqc-tmp/$SERIAL-part-count.txt
#
ifconfig -va | grep -i SFP-10GSR-85| wc -l > swqc-tmp/R20B-10G-SFP-count.txt
ifconfig -va | grep -i SFP-10GSR-85 > swqc-tmp/R20B-10G-SFP-list.txt
ifconfig -va | grep -i SFP-10GSR-85 | wc -l  >> swqc-tmp/$SERIAL-part-count.txt
ifconfig -va | grep -i SFP-10GSR-85 | wc -l >> swqc-tmp/$SERIAL-diffme.txt
ifconfig -va | grep -i SFP-10GSR-85 | wc -l >> swqc-tmp/swqc-output.txt
#
#
fi
#
#
#
if echo "$PRODUCT"|grep -Fwqi -e TRUENAS-R20B  && ifconfig -va | grep -oh "\w*SM10G-SR\w*"| grep -Fwqi -e SM10G-SR; then
echo "10G SFP Count" >> swqc-tmp/swqc-output.txt
echo "10G SFP Count" >> swqc-tmp/$SERIAL-diffme.txt
echo "10G SFP Count" >> swqc-tmp/$SERIAL-part-count.txt
#
ifconfig -va | grep -i SM10G-SR| wc -l > swqc-tmp/R20B-10G-SFP-count.txt
ifconfig -va | grep -i SM10G-SR > swqc-tmp/R20B-10G-SFP-list.txt
ifconfig -va | grep -i SM10G-SR | wc -l  >> swqc-tmp/$SERIAL-part-count.txt
ifconfig -va | grep -i SM10G-SR | wc -l >> swqc-tmp/$SERIAL-diffme.txt
ifconfig -va | grep -i SM10G-SR | wc -l >> swqc-tmp/swqc-output.txt
#
#
fi
#
#
#
if echo "$PRODUCT"|grep -Fwqi -e TRUENAS-R20B  && ifconfig -va | grep -oh "\w*25GBASE-SR\w*"| grep -Fwqi -e 25GBASE-SR; then
echo "25G SFP Count" >> swqc-tmp/swqc-output.txt
echo "25G SFP Count" >> swqc-tmp/$SERIAL-diffme.txt
echo "25G SFP Count" >> swqc-tmp/$SERIAL-part-count.txt
#
ifconfig -va | grep -i 25GBASE-SR| wc -l > swqc-tmp/R20B-25G-SFP-count.txt
ifconfig -va | grep -i 25GBASE-SR > swqc-tmp/R20B-25G-SFP-list.txt
ifconfig -va | grep -i 25GBASE-SR | wc -l  >> swqc-tmp/$SERIAL-part-count.txt
ifconfig -va | grep -i 25GBASE-SR | wc -l >> swqc-tmp/$SERIAL-diffme.txt
ifconfig -va | grep -i 25GBASE-SR | wc -l >> swqc-tmp/swqc-output.txt
#
#
fi
#
#
#
if echo "$PRODUCT"|grep -Fwqi -e TRUENAS-R20B  && ifconfig -va | grep -oh "\w*QSFP-SR4-40G\w*"| grep -Fwqi -e QSFP-SR4-40G; then
echo "40G SFP Count" >> swqc-tmp/swqc-output.txt
echo "40G SFP Count" >> swqc-tmp/$SERIAL-diffme.txt
echo "40G SFP Count" >> swqc-tmp/$SERIAL-part-count.txt
#
ifconfig -va | grep -i QSFP-SR4-40G | wc -l > swqc-tmp/R20B-40G-SFP-count.txt
ifconfig -va | grep -i QSFP-SR4-40G > swqc-tmp/R20B-40G-SFP-list.txt
ifconfig -va | grep -i QSFP-SR4-40G | wc -l  >> swqc-tmp/$SERIAL-part-count.txt
ifconfig -va | grep -i QSFP-SR4-40G | wc -l >> swqc-tmp/$SERIAL-diffme.txt
ifconfig -va | grep -i QSFP-SR4-40G | wc -l >> swqc-tmp/swqc-output.txt
#
#
fi
#
#
#
echo "Read / Write Cache Provisioning Verification" >> swqc-tmp/$SERIAL-diffme.txt
#	
if echo "$PRODUCT" | grep -Eqi 'TRUENAS-R20'; then	
#	
#echo "READ / Write Cache capacity check"  >> swqc-tmp/$SERIAL-part-count.txt	
#echo "READ / Write Cache capacity check" >> swqc-tmp/$SERIAL-diffme.txt	
camcontrol devlist | grep -i MTFDDAK960TDS |cut -d " " -f12 |cut -d "," -f2 | sed 's/)//g'| grep -v ses | xargs -I DRIVE smartctl -x /dev/DRIVE| grep -Ei "device model: | serial number|user capacity"  >> swqc-tmp/$SERIAL-read-write-cache.txt	
#	
#	
fi	
#	
#
if echo "$PRODUCT" | grep -Eqi 'TRUENAS-R20' && cat swqc-tmp/$SERIAL-read-write-cache.txt | grep -oh "\w*16.0 GB\w*"| grep -Fwqi -e "16.0 GB"; then	
echo "Write Cache Correctly OP to 16.0 GB" >> swqc-tmp/$SERIAL-diffme.txt		
#	
#	
fi	
#	
#	
if echo "$PRODUCT" | grep -Eqi 'TRUENAS-R20' && cat swqc-tmp/$SERIAL-read-write-cache.txt | grep -oh "\w*800 GB\w*"| grep -Fwqi -e "800 GB"; then	
echo "Read Cache 800 GB present" >> swqc-tmp/$SERIAL-diffme.txt	
echo "Read Cache  800 GB Present" >> swqc-tmp/$SERIAL-diffme.txt	
#	
#	
fi	
#	
#
#
#
#
echo "===============================" >> swqc-tmp/swqc-output.txt
#
echo "point check J" >> swqc-tmp/swqc-output.txt
echo "point check J" > swqc-tmp/pointcheck-J.txt
#
cd /tmp
#
##################################################################
#
#
echo "===============================" >> swqc-tmp/swqc-output.txt
#
# SWQC check for TRUENAS-M40-S
#
if echo "$PRODUCT"| grep -Fwqi -e "Product Name: TRUENAS-M40-S"; then
#
echo "TrueNAS M40 Specific valadation" >> swqc-tmp/swqc-output.txt
#
#
#
#
fi
#
#
#
#
#Bios for TRUENAS-M40 should be 3.3.V6
#
#
if echo "$PRODUCT"| grep -Fwqi -e "Product Name: TRUENAS-M40-S" && echo "$BIOVER" | grep -oh "\w*3.3.V6\w*"| grep -Fwqi -e 3.3.V6; then
#
#
#
echo "Bios version" >> swqc-tmp/swqc-output.txt
echo "Bios version for TRUENAS-M40 is correctly showing as  3.3.V6"  >> swqc-tmp/swqc-output.txt
echo "Bios version for TRUENAS-M40 is correctly showing as  3.3.V6"  > swqc-tmp/m40-bios.txt
echo "Bios version" >> swqc-tmp/$SERIAL-part-count.txt
echo "Bios version for TRUENAS-M40 is correctly showing as  3.3.V6" >> swqc-tmp/$SERIAL-part-count.txt
echo "Bios version" >> swqc-tmp/$SERIAL-diffme.txt
echo "Correctly showing as  3.3.V6" >> swqc-tmp/$SERIAL-diffme.txt
echo "Bios Version" >> swqc-tmp/$SERIAL-PorF.txt  
echo "pass" >> swqc-tmp/$SERIAL-PorF.txt 
#
elif echo "$PRODUCT"| grep -Fwqi -e "Product Name: TRUENAS-M40-S" && echo "$BIOVER" | grep -oh "\w*3.3.V6\w*" != 3.3.V6; then
#
echo "Bios version for TRUENAS-M40 is showing as $BIOVER it should be  3.3.V6" >> swqc-tmp/swqc-output.txt
echo "Bios version for TRUENAS-M40 is showing as $BIOVER it should be  3.3.V6" > swqc-tmp/m40-bios.txt
echo "Bios version for TRUENAS-M40 is showing as $BIOVER it should be  3.3.V6" >> swqc-tmp/warning.txt
echo "Bios version" >> swqc-tmp/$SERIAL-part-count.txt
echo "Bios version is showing as $BIOVER it should be  3.3.V6" >> swqc-tmp/$SERIAL-part-count.txt
echo "Bios version" >> swqc-tmp/$SERIAL-diffme.txt
echo "Bios version is showing as $BIOVER it should be  3.3.V6" >> swqc-tmp/$SERIAL-diffme.txt
echo "Bios Version" >> swqc-tmp/$SERIAL-PorF.txt  
echo "fail" >> swqc-tmp/$SERIAL-PorF.txt 
#
#
M40BIOV=$(cat swqc-tmp/m40-bios.txt)
#
#
fi
#
#
if echo "$PRODUCT"| grep -Fwqi -e "Product Name: TRUENAS-M40-S" && echo "$BMCINFO" | grep -oh "\w*6.71\w*"| grep -Fwqi -e 6.71; then
#
echo "BMC Firmware "  >> swqc-tmp/swqc-output.txt
echo "Correctly showing as $BMCINFO it should be  6.71" >> swqc-tmp/swqc-output.txt
echo "BMC firmware for TRUENAS-M40 is correctly showing as $BMCINFO it should be  6.71" > swqc-tmp/M40-bmc.txt
echo " BMC Firmware"  >> swqc-tmp/$SERIAL-part-count.txt
echo "BMC firmware for TRUENAS-M40 is correctly showing as $BMCINFO it should be  6.71"  >> swqc-tmp/$SERIAL-part-count.txt
echo " BMC Firmware" >> swqc-tmp/$SERIAL-diffme.txt
echo "Correctly showing as $BMCINFO it should be  6.71" >> swqc-tmp/$SERIAL-diffme.txt
echo "BMC Firmware" >> swqc-tmp/$SERIAL-PorF.txt  
echo "fail" >> swqc-tmp/$SERIAL-PorF.txt 
#
#
elif echo "$PRODUCT"| grep -Fwqi -e "Product Name: TRUENAS-M40-S" && echo "$BMCINFO" | grep -oh "\w*6.71\w*" != 6.71; then
#
echo "BMC Firmware for TRUENAS-M40 is showing as $BMCINFO it should be  6.71" >> swqc-tmp/swqc-output.txt
echo "BMC Firmware for TRUENAS-M40 is showing as $BMCINFO it should be  6.71" > swqc-tmp/M40-bmc.txt
echo "BMC Firmware for TRUENAS-M40 is showing as $BMCINFO it should be  6.71" >> swqc-tmp/warning.txt
echo " BMC Firmware"  >> swqc-tmp/$SERIAL-part-count.txt
echo "BMC Firmware is showing as $BMCINFO it should be  6.71" >> swqc-tmp/$SERIAL-part-count.txt
echo " BMC Firmware" >> swqc-tmp/$SERIAL-diffme.txt
echo "BMC Firmware is showing as $BMCINFO it should be  6.71" >> swqc-tmp/$SERIAL-diffme.txt
echo "BMC Firmware" >> swqc-tmp/$SERIAL-PorF.txt  
echo "fail" >> swqc-tmp/$SERIAL-PorF.txt 
#
#
M40BMC=$(cat swqc-tmp/M40-bmc.txt)
#
#
fi
#
#
# IX-TN-M40-S-V.02
#
#
if echo "$PRODUCT"| grep -Fwqi -e "Product Name: TRUENAS-M40-S"; then
#
echo "CheckPoint 1 Product Name: TRUENAS-M40-S" > m40-checkpoint1.txt
# Software Validation of x16 NTB
#
pciconf -lvcb ntb_hw0 | egrep 'PLX|8732|x16\(x16\) speed 8.0\(8.0\)' > swqc-tmp/ntb_hw0.txt
pciconf -lvcb ntb_hw0 | egrep 'PLX|8732|x16\(x16\) speed 8.0\(8.0\)'  >> swqc-tmp/swqc-output.txt
#
#
NTBHW0=$(cat swqc-tmp/ntb_hw0.txt)
#
#Ensure that the following 3 lines are returned by command:
#
#vendor     = 'PLX Technology, Inc.'
#device     = 'PEX 8732 32-lane, 8-Port PCI Express Gen 3 (8.0 GT/s)
#link x16(x16) speed 8.0(8.0) ASPM disabled(L0s/L1)
#
#
#  check the connection between both controllers NTB:
#  
#
grep ntb_hw /var/log/messages | grep "ntb_hw0: Link is up (PCIe 3.x / x8)" > swqc-tmp/ntb_hw0-link-status.txt # Note:if Single node controller result will be blank
grep ntb_hw /var/log/messages | grep "ntb_hw0: Link is up (PCIe 3.x / x8)" >> swqc-tmp/swqc-output.txt  # Note:if Single node controller result will be blank
#
#
NTBHW0linkstatus=$(cat swqc-tmp/ntb_hw0-link-status.txt)
#
# Ensure that "Link is up" message is returned
#
#
# NTB Window Size
#
pciconf -lvcb ntb_hw0 |egrep "bar.*\[18]"|cut -w -f 12-13 >> swqc-tmp/swqc-output.txt
pciconf -lvcb ntb_hw0 |egrep "bar.*\[18]"|cut -w -f 12-13 > swqc/ntb_hw0_windowsize.txt
#
#
NTBWINDOWSIZE=$(cat swqc/ntb_hw0_windowsize.txt)
#
#
# Size should be size    274877906944,
#
echo "===============================" >> swqc-tmp/swqc-output.txt
#
#
# “Cub” SAS Expander
# 
# 
# 
sesutil map  -u/dev/ses2 |grep LSISAS35 >> swqc-tmp/swqc-output.txt
sesutil map  -u/dev/ses2 |grep LSISAS35 > swqc-tmp/cubsas.txt
#
#
CUBSAS=$(cat swqc-tmp/cubsas.txt)
#
#
# Ensure the following is returned  Description: H24R-3X.R2D (LSISAS35Exp) 
#
echo "===============================" >> swqc-tmp/swqc-output.txt
#
# Software Validation for TrueNAS M40 
#
# The M40G3 128GB controller should have 4x16 GiB ECC RDIMMs installed to make up it’s 128GB of ram, populating 4 out of the 6 blue memory slots on the X11SPi-TF board. 
# The model number is RD4R32G48H2666.
#
#
# Software Validation of 256GB Memory
#
#
dmidecode -t memory |grep Part|grep HMA84GR7AFR4N-VK|wc -l >> swqc-tmp/swqc-output.txt
dmidecode -t memory |grep Part|grep HMA84GR7AFR4N-VK|wc -l > swqc-tmp/M40_256_memory_count.txt
#
M40_256_MEMCOUNT=$(cat swqc-tmp/M40_256_memory_count.txt) 
#
# Validate the output is 4 as that is the number of 4x16 GiB ECC RDIMMs  installed
#
#
# Valadate the ram is in the correct slots
#
#
dmidecode -t memory|grep "^[[:blank:]]Locator:\|Part"|grep -B1 HMA84GR7AFR4N-VK |grep Locator >> swqc-tmp/swqc-output.txt
dmidecode -t memory|grep "^[[:blank:]]Locator:\|Part"|grep -B1 HMA84GR7AFR4N-VK |grep Locator > swqc-tmp/M40-256-ram-slot-check.txt
#
#
M40_256_RAMSLOTS=$(cat swqc-tmp/M40-256-ram-slot-check.txt)
#
# Valadate that the ram is in the correct solts 4x16 GiB ECC RDIMMs on each processor
# The ram should be in slots A1,B1,D1,E1.
#
#
echo "===============================" >> swqc-tmp/swqc-output.txt
#
# Software Validation of 192GB Memory
#
#
dmidecode -t memory |grep Part|grep HMA84GR7AFR4N-VK|wc -l >> swqc-tmp/swqc-output.txt
dmidecode -t memory |grep Part|grep HMA84GR7AFR4N-VK|wc -l > M40-192GB-Memory-Count.txt
#
#
M40_192_MEMCOUNT=$(cat M40-192GB-Memory-Count.txt)
#
#
# Validate the output is 6 as that is the number of 64GB RDimms installed:
#
#
#
Validate that the ram is in the correct slots
#
#
dmidecode -t memory|grep "^[[:blank:]]Locator:\|Part"|grep -B1 HMA84GR7AFR4N-VK |grep Locator >> swqc-tmp/swqc-output.txt
dmidecode -t memory|grep "^[[:blank:]]Locator:\|Part"|grep -B1 HMA84GR7AFR4N-VK |grep Locator > swqc-tmp/M40-192-ram-slot-check.tx
#
#
M40_192_RAMSLOTS=$(cat swqc-tmp/M40-192-ram-slot-check.txt)
#
# The ram should be in slots A1-F1 on each processor
# 
#
#
#
#
#
echo "===============================" >> swqc-tmp/swqc-output.txt
#
# Software Validation of NVDIMMs for M40 
#
#
dmidecode -t memory |grep Part|grep 18ASF2G72PF12G9WP1AB|wc -l >> swqc-tmp/swqc-output.txt
dmidecode -t memory |grep Part|grep 18ASF2G72PF12G9WP1AB|wc -l > swqc-tmp/M40-nvdimm-valadation.txt
#
# 1 is the expected value
#
M40NVDIMMVALADATION=$(cat swqc-tmp/M40-nvdimm-valadation.txt)
#
#
echo "===============================" >> swqc-tmp/swqc-output.txt
#
# Validate that both NVDIMMs setup to sync across NTB
#
#
dmesg |grep 'NTB PMEM syncer'  >> swqc-tmp/swqc-output.txt
dmesg |grep 'NTB PMEM syncer' > swqc-tmp/nvdimm-sync-ntb.txt
#
#
M40NBDIMMSYNC=$(cat swqc-tmp/nvdimm-sync-ntb.txt)
#
# If only one PMEM syncer appears, you may be missing the required loader tunables that enable dual PMEM.
# If no NTB syncers appear, then there may be a serious configuration issue and the issue must be investigated and resolved
#
# expected results : 
# 
# ntb_pmem0: <NTB PMEM syncer> mw 0 spad 0-3 at function 0 numa-domain 0 on ntb_hw0
#
# ntb_pmem1: <NTB PMEM syncer> mw 1 spad 4-7 at function 1 numa-domain 0 on ntb_hw0
#
echo "===============================" >> swqc-tmp/swqc-output.txt
#
#
# Validate that the NVDIMM is in the correct slot 
#
#
dmidecode -t memory|grep "^[[:blank:]]Locator:\|Part"|grep -B1 18ASF2G72PF12G9WP1AB|grep Locator >> swqc-tmp/swqc-output.txt
dmidecode -t memory|grep "^[[:blank:]]Locator:\|Part"|grep -B1 18ASF2G72PF12G9WP1AB|grep Locator > swqc-tmp/nvdimm-locator.txt
#
NVDIMLOC=$(cat swqc-tmp/nvdimm-locator.txt)
#
#
# Locator:\|Part|grep -B1 18ASF2G72PF12G9WP1AB|grep Locator Locator: P1-DIMMA2
# The ram should be in slots A2 on the first Processor P1
#
#
#
#
# M40 Fan valadation
#
#
ipmitool sensor list | egrep "FAN[34AB]" | cut -d\| -f1-3  >> swqc-tmp/swqc-output.txt
ipmitool sensor list | egrep "FAN[34AB]" | cut -d\| -f1-3 > swqc-tmp/M40-FAN-RPM-CHECK.txt
#
M40FANRPM=$(cat swqc-tmp/M40-FAN-RPM-CHECK.txt)
#
#
#Validate the output shows FAN3 as na
#
#
#
echo "===============================" >> swqc-tmp/swqc-output.txt
#
#
# Ensure that the M40 Fans are set to standard
#
#
ipmitool raw 0x30 0x45 0x00 >> swqc-tmp/swqc-output.txt
ipmitool raw 0x30 0x45 0x00 > swqc-tmp/M40-fan-Setting-check.txt
#
M40FANSETTINGS=$(cat swqc-tmp-/m40-fan-Setting-check.txt)
#
#It should return 00
#
#
#
#
echo "===============================" >> swqc-tmp/swqc-output.txt
#
# Collecting drive temp for M40
#
#
#
echo "Current Drive Temps " >> swqc-tmp/swqc-output.txt
#
echo "Drive Check to ensure everthing is below 60C:"  >> swqc-tmp/swqc-output.txt
#
camcontrol devlist | cut -d, -f2 | tr -d \) | grep -v ses | xargs -I DRIVE smartctl -A /dev/DRIVE | grep -i temperature | grep -i current >> swqc-tmp/swqc-output.txt
camcontrol devlist | cut -d, -f2 | tr -d \) | grep -v ses | xargs -I DRIVE smartctl -A /dev/DRIVE | grep -i temperature | grep -i current > swqc-tmp/m40drivetemp-output.txt
#
#
M400DRIVETEMP=$(cat swqc-tmp/m40drivetemp-output.txt)
#
#
echo "CheckPoint 2 Product Name: TRUENAS-M40-S" > m40-checkpoint1.txt
#
fi
#
#
#
#
#
#
#
if echo "$PRODUCT"| grep -Fwqi -e "Product Name: TRUENAS-M40-S" && pciconf -lvcb | grep -oh "\w*T6225-SO-CR\w*"| grep -Fwqi -e T62100-LP-CR; then
echo "Add on nic card" >> swqc-tmp/swqc-output.txt
echo "Add on nic card" >> swqc-tmp/$SERIAL-diffme.txt
echo "Add on nic card" >> swqc-tmp/$SERIAL-part-count.txt
#
pciconf -lvcb | grep -i T62100-LP-CR | wc -l > swqc-tmp/M40-add-on-nic-count.txt
pciconf -lvcb | grep -i T62100-LP-CR | wc -l  >> swqc-tmp/$SERIAL-part-count.txt
pciconf -lvcb | grep -i T62100-LP-CR | wc -l  >> swqc-tmp/M40-25GB-nic-list-part.txt
pciconf -lvcb | grep -i T62100-LP-CR| wc -l  >> swqc-tmp/$SERIAL-diffme.txt
pciconf -lvcb | grep -i T62100-LP-CR| wc -l >> swqc-tmp/swqc-output.txt
#
#
fi
#
#
#
if echo "$PRODUCT"| grep -Fwqi -e "Product Name: TRUENAS-M40-S" && pciconf -lvcb | grep -oh "\w*T62100-LP-CR\w*"| grep -Fwqi -e T62100-LP-CR; then
echo "Add on nic card" >> swqc-tmp/swqc-output.txt
echo "Add on nic card" >> swqc-tmp/$SERIAL-diffme.txt
echo "Add on nic card" >> swqc-tmp/$SERIAL-part-count.txt
#
pciconf -lvcb | grep -i T62100-LP-CR | wc -l > swqc-tmp/M40-add-on-nic-count.txt
pciconf -lvcb | grep -i T62100-LP-CR | wc -l  >> swqc-tmp/$SERIAL-part-count.txt
pciconf -lvcb | grep -i T62100-LP-CR| wc -l  >> swqc-tmp/$SERIAL-diffme.txt
pciconf -lvcb | grep -i T62100-LP-CR| wc -l >> swqc-tmp/swqc-output.txt
#
#
fi
#
#
#
#
#
if echo "$PRODUCT"| grep -Fwqi -e "Product Name: TRUENAS-M40-S" && ifconfig -va | grep -oh "\w*SM10G-SR\w*"| grep -Fwqi -e SM10G-SR; then
echo "10G SFP Count" >> swqc-tmp/swqc-output.txt
echo "10G SFP Count" >> swqc-tmp/$SERIAL-diffme.txt
echo "10G SFP Count" >> swqc-tmp/$SERIAL-part-count.txt
#
ifconfig -va | grep -i SM10G-SR| wc -l > swqc-tmp/M40-10G-SFP-count.txt
ifconfig -va | grep -i SM10G-SR > swqc-tmp/M40-10G-SFP-list.txt
ifconfig -va | grep -i SM10G-SR | wc -l  >> swqc-tmp/$SERIAL-part-count.txt
ifconfig -va | grep -i SM10G-SR | wc -l >> swqc-tmp/$SERIAL-diffme.txt
ifconfig -va | grep -i SM10G-SR | wc -l >> swqc-tmp/swqc-output.txt
#
#
fi
#
#
#
if echo "$PRODUCT"| grep -Fwqi -e "Product Name: TRUENAS-M40-S" && ifconfig -va | grep -oh "\w*25GBASE-SR\w*"| grep -Fwqi -e 25GBASE-SR; then
echo "25G SFP Count" >> swqc-tmp/swqc-output.txt
echo "25G SFP Count" >> swqc-tmp/$SERIAL-diffme.txt
echo "25G SFP Count" >> swqc-tmp/$SERIAL-part-count.txt
#
ifconfig -va | grep -i 25GBASE-SR| wc -l > swqc-tmp/M40-25G-SFP-count.txt
ifconfig -va | grep -i 25GBASE-SR > swqc-tmp/M40-25G-SFP-list.txt
ifconfig -va | grep -i 25GBASE-SR | wc -l  >> swqc-tmp/$SERIAL-part-count.txt
ifconfig -va | grep -i 25GBASE-SR | wc -l >> swqc-tmp/$SERIAL-diffme.txt
ifconfig -va | grep -i 25GBASE-SR | wc -l >> swqc-tmp/swqc-output.txt
#
#
fi
#
#
#
if echo "$PRODUCT"| grep -Fwqi -e "Product Name: TRUENAS-M40-S" && ifconfig -va | grep -oh "\w*QSFP-SR4-40G\w*"| grep -Fwqi -e QSFP-SR4-40G; then
echo "40G SFP Count" >> swqc-tmp/swqc-output.txt
echo "40G SFP Count" >> swqc-tmp/$SERIAL-diffme.txt
echo "40G SFP Count" >> swqc-tmp/$SERIAL-part-count.txt
#
ifconfig -va | grep -i QSFP-SR4-40G | wc -l > swqc-tmp/R20B-40G-SFP-count.txt
ifconfig -va | grep -i QSFP-SR4-40G > swqc-tmp/M40-40G-SFP-list.txt
ifconfig -va | grep -i QSFP-SR4-40G | wc -l  >> swqc-tmp/$SERIAL-part-count.txt
ifconfig -va | grep -i QSFP-SR4-40G | wc -l >> swqc-tmp/$SERIAL-diffme.txt
ifconfig -va | grep -i QSFP-SR4-40G | wc -l >> swqc-tmp/swqc-output.txt
#
#
fi
#
#
#
#
#
#
echo "===============================" >> swqc-tmp/swqc-output.txt
#
cd /tmp
#
echo "point check k" >> swqc-tmp/swqc-output.txt
echo "point check k" > swqc-tmp/pointcheck-k.txt
#
#
#
#
#
#
echo "===============================" >> swqc-tmp/swqc-output.txt
#
# 
###################################################################
#
#
#
echo "===============================" >> swqc-tmp/swqc-output.txt
#
# SWQC check for TRUENAS-M40-HA
#
if echo "$PRODUCT"| grep -Fwqi -e "Product Name: TRUENAS-M40-HA"; then
#
echo "TrueNAS M40 Specific valadation" >> swqc-tmp/swqc-output.txt
#
#
#
#
fi
#
#
#
#
#Bios for TRUENAS-M40 should be 3.3.V6
#
#
if echo "$PRODUCT"| grep -Fwqi -e "Product Name: TRUENAS-M40-HA" && echo "$BIOVER" | grep -oh "\w*3.3.V6\w*"| grep -Fwqi -e 3.3.V6; then
#
#
#
echo "Bios version" >> swqc-tmp/swqc-output.txt
echo "Bios version for TRUENAS-M40 is correctly showing as  3.3.V6"  >> swqc-tmp/swqc-output.txt
echo "Bios version for TRUENAS-M40 is correctly showing as  3.3.V6"  > swqc-tmp/m40-bios.txt
echo "Bios version" >> swqc-tmp/$SERIAL-part-count.txt
echo "Bios version for TRUENAS-M40 is correctly showing as  3.3.V6" >> swqc-tmp/$SERIAL-part-count.txt
echo "Bios version" >> swqc-tmp/$SERIAL-diffme.txt
echo "Correctly showing as  3.3.V6" >> swqc-tmp/$SERIAL-diffme.txt
echo "Bios Version" >> swqc-tmp/$SERIAL-PorF.txt  
echo "pass" >> swqc-tmp/$SERIAL-PorF.txt 
#

elif echo "$PRODUCT"| grep -Fwqi -e "Product Name: TRUENAS-M40-HA" && echo "$BIOVER" | grep -oh "\w*3.3.V6\w*" != 3.3.V6; then
#
echo "Bios version for TRUENAS-M40 is showing as $BIOVER it should be  3.3.V6" >> swqc-tmp/swqc-output.txt
echo "Bios version for TRUENAS-M40 is showing as $BIOVER it should be  3.3.V6" > swqc-tmp/m40-bios.txt
echo "Bios version for TRUENAS-M40 is showing as $BIOVER it should be  3.3.V6" >> swqc-tmp/warning.txt
echo "Bios version" >> swqc-tmp/$SERIAL-part-count.txt
echo "Bios version is showing as $BIOVER it should be  3.3.V6" >> swqc-tmp/$SERIAL-part-count.txt
echo "Bios version" >> swqc-tmp/$SERIAL-diffme.txt
echo "Bios version is showing as $BIOVER it should be  3.3.V6" >> swqc-tmp/$SERIAL-diffme.txt
echo "Bios Version" >> swqc-tmp/$SERIAL-PorF.txt  
echo "fail" >> swqc-tmp/$SERIAL-PorF.txt 
#
#
M40BIOV=$(cat swqc-tmp/m40-bios.txt)
#
#
fi
#
#
if echo "$PRODUCT"| grep -Fwqi -e "Product Name: TRUENAS-M40-HA" && echo "$BMCINFO" | grep -oh "\w*6.71\w*"| grep -Fwqi -e 6.71; then
#
echo "BMC Firmware "  >> swqc-tmp/swqc-output.txt
echo "Correctly showing as $BMCINFO it should be  6.71" >> swqc-tmp/swqc-output.txt
echo "BMC firmware for TRUENAS-M40 is correctly showing as $BMCINFO it should be  6.71" > swqc-tmp/M40-bmc.txt
echo " BMC Firmware"  >> swqc-tmp/$SERIAL-part-count.txt
echo "BMC firmware for TRUENAS-M40 is correctly showing as $BMCINFO it should be  6.71"  >> swqc-tmp/$SERIAL-part-count.txt
echo " BMC Firmware" >> swqc-tmp/$SERIAL-diffme.txt
echo "Correctly showing as $BMCINFO it should be  6.71" >> swqc-tmp/$SERIAL-diffme.txt
echo "BMC Firmware" >> swqc-tmp/$SERIAL-PorF.txt  
echo "fail" >> swqc-tmp/$SERIAL-PorF.txt 
#
#
elif echo "$PRODUCT"| grep -Fwqi -e "Product Name: TRUENAS-M40-HA" && echo "$BMCINFO" | grep -oh "\w*6.71\w*" != 6.71; then
#
echo "BMC Firmware for TRUENAS-M40 is showing as $BMCINFO it should be  6.71" >> swqc-tmp/swqc-output.txt
echo "BMC Firmware for TRUENAS-M40 is showing as $BMCINFO it should be  6.71" > swqc-tmp/M40-bmc.txt
echo "BMC Firmware for TRUENAS-M40 is showing as $BMCINFO it should be  6.71" >> swqc-tmp/warning.txt
echo " BMC Firmware"  >> swqc-tmp/$SERIAL-part-count.txt
echo "BMC Firmware is showing as $BMCINFO it should be  6.71" >> swqc-tmp/$SERIAL-part-count.txt
echo " BMC Firmware" >> swqc-tmp/$SERIAL-diffme.txt
echo "BMC Firmware is showing as $BMCINFO it should be  6.71" >> swqc-tmp/$SERIAL-diffme.txt
echo "BMC Firmware" >> swqc-tmp/$SERIAL-PorF.txt  
echo "fail" >> swqc-tmp/$SERIAL-PorF.txt 
#
#
M40BMC=$(cat swqc-tmp/M40-bmc.txt)
#
#
fi
#
#
# IX-TN-M40-S-V.02
#
#
if echo "$PRODUCT"| grep -Fwqi -e "Product Name: TRUENAS-M40-HA"; then
#
echo "CheckPoint 1 Product Name: TRUENAS-M40-HA" > m40-checkpoint1.txt
# Software Validation of x16 NTB
#
pciconf -lvcb ntb_hw0 | egrep 'PLX|8732|x16\(x16\) speed 8.0\(8.0\)' > swqc-tmp/ntb_hw0.txt
pciconf -lvcb ntb_hw0 | egrep 'PLX|8732|x16\(x16\) speed 8.0\(8.0\)'  >> swqc-tmp/swqc-output.txt
#
#
NTBHW0=$(cat swqc-tmp/ntb_hw0.txt)
#
#Ensure that the following 3 lines are returned by command:
#
#vendor     = 'PLX Technology, Inc.'
#device     = 'PEX 8732 32-lane, 8-Port PCI Express Gen 3 (8.0 GT/s)
#link x16(x16) speed 8.0(8.0) ASPM disabled(L0s/L1)
#
#
#  check the connection between both controllers NTB:
#  
#
grep ntb_hw /var/log/messages | grep "ntb_hw0: Link is up (PCIe 3.x / x8)" > swqc-tmp/ntb_hw0-link-status.txt # Note:if Single node controller result will be blank
grep ntb_hw /var/log/messages | grep "ntb_hw0: Link is up (PCIe 3.x / x8)" >> swqc-tmp/swqc-output.txt  # Note:if Single node controller result will be blank
#
#
NTBHW0linkstatus=$(cat swqc-tmp/ntb_hw0-link-status.txt)
#
# Ensure that "Link is up" message is returned
#
#
# NTB Window Size
#
pciconf -lvcb ntb_hw0 |egrep "bar.*\[18]"|cut -w -f 12-13 >> swqc-tmp/swqc-output.txt
pciconf -lvcb ntb_hw0 |egrep "bar.*\[18]"|cut -w -f 12-13 > swqc/ntb_hw0_windowsize.txt
#
#
NTBWINDOWSIZE=$(cat swqc/ntb_hw0_windowsize.txt)
#
#
# Size should be size    274877906944,
#
echo "===============================" >> swqc-tmp/swqc-output.txt
#
#
# “Cub” SAS Expander
# 
# 
# 
sesutil map  -u/dev/ses2 |grep LSISAS35 >> swqc-tmp/swqc-output.txt
sesutil map  -u/dev/ses2 |grep LSISAS35 > swqc-tmp/cubsas.txt
#
#
CUBSAS=$(cat swqc-tmp/cubsas.txt)
#
#
# Ensure the following is returned  Description: H24R-3X.R2D (LSISAS35Exp) 
#
echo "===============================" >> swqc-tmp/swqc-output.txt
#
# Software Validation for TrueNAS M40 
#
# The M40G3 128GB controller should have 4x16 GiB ECC RDIMMs installed to make up it’s 128GB of ram, populating 4 out of the 6 blue memory slots on the X11SPi-TF board. 
# The model number is RD4R32G48H2666.
#
#
# Software Validation of 256GB Memory
#
#
dmidecode -t memory |grep Part|grep HMA84GR7AFR4N-VK|wc -l >> swqc-tmp/swqc-output.txt
dmidecode -t memory |grep Part|grep HMA84GR7AFR4N-VK|wc -l > swqc-tmp/M40_256_memory_count.txt
#
M40_256_MEMCOUNT=$(cat swqc-tmp/M40_256_memory_count.txt) 
#
# Validate the output is 4 as that is the number of 4x16 GiB ECC RDIMMs  installed
#
#
# Valadate the ram is in the correct slots
#
#
dmidecode -t memory|grep "^[[:blank:]]Locator:\|Part"|grep -B1 HMA84GR7AFR4N-VK |grep Locator >> swqc-tmp/swqc-output.txt
dmidecode -t memory|grep "^[[:blank:]]Locator:\|Part"|grep -B1 HMA84GR7AFR4N-VK |grep Locator > swqc-tmp/M40-256-ram-slot-check.txt
#
#
M40_256_RAMSLOTS=$(cat swqc-tmp/M40-256-ram-slot-check.txt)
#
# Valadate that the ram is in the correct solts 4x16 GiB ECC RDIMMs on each processor
# The ram should be in slots A1,B1,D1,E1.
#
#
echo "===============================" >> swqc-tmp/swqc-output.txt
#
# Software Validation of 192GB Memory
#
#
dmidecode -t memory |grep Part|grep HMA84GR7AFR4N-VK|wc -l >> swqc-tmp/swqc-output.txt
dmidecode -t memory |grep Part|grep HMA84GR7AFR4N-VK|wc -l > M40-192GB-Memory-Count.txt
#
#
M40_192_MEMCOUNT=$(cat M40-192GB-Memory-Count.txt)
#
#
# Validate the output is 6 as that is the number of 64GB RDimms installed:
#
#
#
Validate that the ram is in the correct slots
#
#
dmidecode -t memory|grep "^[[:blank:]]Locator:\|Part"|grep -B1 HMA84GR7AFR4N-VK |grep Locator >> swqc-tmp/swqc-output.txt
dmidecode -t memory|grep "^[[:blank:]]Locator:\|Part"|grep -B1 HMA84GR7AFR4N-VK |grep Locator > swqc-tmp/M40-192-ram-slot-check.tx
#
#
M40_192_RAMSLOTS=$(cat swqc-tmp/M40-192-ram-slot-check.txt)
#
# The ram should be in slots A1-F1 on each processor
# 
#
#
#
#
#
echo "===============================" >> swqc-tmp/swqc-output.txt
#
# Software Validation of NVDIMMs for M40 
#
#
dmidecode -t memory |grep Part|grep 18ASF2G72PF12G9WP1AB|wc -l >> swqc-tmp/swqc-output.txt
dmidecode -t memory |grep Part|grep 18ASF2G72PF12G9WP1AB|wc -l > swqc-tmp/M40-nvdimm-valadation.txt
#
# 1 is the expected value
#
M40NVDIMMVALADATION=$(cat swqc-tmp/M40-nvdimm-valadation.txt)
#
#
echo "===============================" >> swqc-tmp/swqc-output.txt
#
# Validate that both NVDIMMs setup to sync across NTB
#
#
dmesg |grep 'NTB PMEM syncer'  >> swqc-tmp/swqc-output.txt
dmesg |grep 'NTB PMEM syncer' > swqc-tmp/nvdimm-sync-ntb.txt
#
#
M40NBDIMMSYNC=$(cat swqc-tmp/nvdimm-sync-ntb.txt)
#
# If only one PMEM syncer appears, you may be missing the required loader tunables that enable dual PMEM.
# If no NTB syncers appear, then there may be a serious configuration issue and the issue must be investigated and resolved
#
# expected results : 
# 
# ntb_pmem0: <NTB PMEM syncer> mw 0 spad 0-3 at function 0 numa-domain 0 on ntb_hw0
#
# ntb_pmem1: <NTB PMEM syncer> mw 1 spad 4-7 at function 1 numa-domain 0 on ntb_hw0
#
echo "===============================" >> swqc-tmp/swqc-output.txt
#
#
# Validate that the NVDIMM is in the correct slot 
#
#
dmidecode -t memory|grep "^[[:blank:]]Locator:\|Part"|grep -B1 18ASF2G72PF12G9WP1AB|grep Locator >> swqc-tmp/swqc-output.txt
dmidecode -t memory|grep "^[[:blank:]]Locator:\|Part"|grep -B1 18ASF2G72PF12G9WP1AB|grep Locator > swqc-tmp/nvdimm-locator.txt
#
NVDIMLOC=$(cat swqc-tmp/nvdimm-locator.txt)
#
#
# Locator:\|Part|grep -B1 18ASF2G72PF12G9WP1AB|grep Locator Locator: P1-DIMMA2
# The ram should be in slots A2 on the first Processor P1
#
#
#
#
# M40 Fan valadation
#
#
ipmitool sensor list | egrep "FAN[34AB]" | cut -d\| -f1-3  >> swqc-tmp/swqc-output.txt
ipmitool sensor list | egrep "FAN[34AB]" | cut -d\| -f1-3 > swqc-tmp/M40-FAN-RPM-CHECK.txt
#
M40FANRPM=$(cat swqc-tmp/M40-FAN-RPM-CHECK.txt)
#
#
#Validate the output shows FAN3 as na
#
#
#
echo "===============================" >> swqc-tmp/swqc-output.txt
#
#
# Ensure that the M40 Fans are set to standard
#
#
ipmitool raw 0x30 0x45 0x00 >> swqc-tmp/swqc-output.txt
ipmitool raw 0x30 0x45 0x00 > swqc-tmp/M40-fan-Setting-check.txt
#
M40FANSETTINGS=$(cat swqc-tmp-/m40-fan-Setting-check.txt)
#
#It should return 00
#
#
#
#
echo "===============================" >> swqc-tmp/swqc-output.txt
#
# Collecting drive temp for M40
#
#
#
echo "Current Drive Temps " >> swqc-tmp/swqc-output.txt
#
echo "Drive Check to ensure everthing is below 60C:"  >> swqc-tmp/swqc-output.txt
#
camcontrol devlist | cut -d, -f2 | tr -d \) | grep -v ses | xargs -I DRIVE smartctl -A /dev/DRIVE | grep -i temperature | grep -i current >> swqc-tmp/swqc-output.txt
camcontrol devlist | cut -d, -f2 | tr -d \) | grep -v ses | xargs -I DRIVE smartctl -A /dev/DRIVE | grep -i temperature | grep -i current > swqc-tmp/m40drivetemp-output.txt
#
#
M400DRIVETEMP=$(cat swqc-tmp/m40drivetemp-output.txt)
#
#
echo "CheckPoint 2 Product Name: TRUENAS-M40-HA" > m40-checkpoint1.txt
#
fi
#
#
#
#
#
#
#
if echo "$PRODUCT"| grep -Fwqi -e "Product Name: TRUENAS-M40-HA" && pciconf -lvcb | grep -oh "\w*T6225-SO-CR\w*"| grep -Fwqi -e T62100-LP-CR; then
echo "Add on nic card" >> swqc-tmp/swqc-output.txt
echo "Add on nic card" >> swqc-tmp/$SERIAL-diffme.txt
echo "Add on nic card" >> swqc-tmp/$SERIAL-part-count.txt
#
pciconf -lvcb | grep -i T62100-LP-CR | wc -l > swqc-tmp/M40-add-on-nic-count.txt
pciconf -lvcb | grep -i T62100-LP-CR | wc -l  >> swqc-tmp/$SERIAL-part-count.txt
pciconf -lvcb | grep -i T62100-LP-CR | wc -l  >> swqc-tmp/M40-25GB-nic-list-part.txt
pciconf -lvcb | grep -i T62100-LP-CR| wc -l  >> swqc-tmp/$SERIAL-diffme.txt
pciconf -lvcb | grep -i T62100-LP-CR| wc -l >> swqc-tmp/swqc-output.txt
#
#
fi
#
#
#
if echo "$PRODUCT"| grep -Fwqi -e "Product Name: TRUENAS-M40-HA" && pciconf -lvcb | grep -oh "\w*T62100-LP-CR\w*"| grep -Fwqi -e T62100-LP-CR; then
echo "Add on nic card" >> swqc-tmp/swqc-output.txt
echo "Add on nic card" >> swqc-tmp/$SERIAL-diffme.txt
echo "Add on nic card" >> swqc-tmp/$SERIAL-part-count.txt
#
pciconf -lvcb | grep -i T62100-LP-CR | wc -l > swqc-tmp/M40-add-on-nic-count.txt
pciconf -lvcb | grep -i T62100-LP-CR | wc -l  >> swqc-tmp/$SERIAL-part-count.txt
pciconf -lvcb | grep -i T62100-LP-CR| wc -l  >> swqc-tmp/$SERIAL-diffme.txt
pciconf -lvcb | grep -i T62100-LP-CR| wc -l >> swqc-tmp/swqc-output.txt
#
#
fi
#
#
#
#
#
if echo "$PRODUCT"| grep -Fwqi -e "Product Name: TRUENAS-M40-HA" && ifconfig -va | grep -oh "\w*SM10G-SR\w*"| grep -Fwqi -e SM10G-SR; then
echo "10G SFP Count" >> swqc-tmp/swqc-output.txt
echo "10G SFP Count" >> swqc-tmp/$SERIAL-diffme.txt
echo "10G SFP Count" >> swqc-tmp/$SERIAL-part-count.txt
#
ifconfig -va | grep -i SM10G-SR| wc -l > swqc-tmp/M40-10G-SFP-count.txt
ifconfig -va | grep -i SM10G-SR > swqc-tmp/M40-10G-SFP-list.txt
ifconfig -va | grep -i SM10G-SR | wc -l  >> swqc-tmp/$SERIAL-part-count.txt
ifconfig -va | grep -i SM10G-SR | wc -l >> swqc-tmp/$SERIAL-diffme.txt
ifconfig -va | grep -i SM10G-SR | wc -l >> swqc-tmp/swqc-output.txt
#
#
fi
#
#
#
if echo "$PRODUCT"| grep -Fwqi -e "Product Name: TRUENAS-M40-HA" && ifconfig -va | grep -oh "\w*25GBASE-SR\w*"| grep -Fwqi -e 25GBASE-SR; then
echo "25G SFP Count" >> swqc-tmp/swqc-output.txt
echo "25G SFP Count" >> swqc-tmp/$SERIAL-diffme.txt
echo "25G SFP Count" >> swqc-tmp/$SERIAL-part-count.txt
#
ifconfig -va | grep -i 25GBASE-SR| wc -l > swqc-tmp/M40-25G-SFP-count.txt
ifconfig -va | grep -i 25GBASE-SR > swqc-tmp/M40-25G-SFP-list.txt
ifconfig -va | grep -i 25GBASE-SR | wc -l  >> swqc-tmp/$SERIAL-part-count.txt
ifconfig -va | grep -i 25GBASE-SR | wc -l >> swqc-tmp/$SERIAL-diffme.txt
ifconfig -va | grep -i 25GBASE-SR | wc -l >> swqc-tmp/swqc-output.txt
#
#
fi
#
#
#
if echo "$PRODUCT"| grep -Fwqi -e "Product Name: TRUENAS-M40-HA" && ifconfig -va | grep -oh "\w*QSFP-SR4-40G\w*"| grep -Fwqi -e QSFP-SR4-40G; then
echo "40G SFP Count" >> swqc-tmp/swqc-output.txt
echo "40G SFP Count" >> swqc-tmp/$SERIAL-diffme.txt
echo "40G SFP Count" >> swqc-tmp/$SERIAL-part-count.txt
#
ifconfig -va | grep -i QSFP-SR4-40G | wc -l > swqc-tmp/R20B-40G-SFP-count.txt
ifconfig -va | grep -i QSFP-SR4-40G > swqc-tmp/M40-40G-SFP-list.txt
ifconfig -va | grep -i QSFP-SR4-40G | wc -l  >> swqc-tmp/$SERIAL-part-count.txt
ifconfig -va | grep -i QSFP-SR4-40G | wc -l >> swqc-tmp/$SERIAL-diffme.txt
ifconfig -va | grep -i QSFP-SR4-40G | wc -l >> swqc-tmp/swqc-output.txt
#
#
fi
#
#
#
#
#
#
echo "===============================" >> swqc-tmp/swqc-output.txt
#
cd /tmp
#
echo "point check k" >> swqc-tmp/swqc-output.txt
echo "point check k" > swqc-tmp/pointcheck-k.txt
#
#
#
#
#
#
echo "===============================" >> swqc-tmp/swqc-output.txt
#
# 
###################################################################
#
#
if echo "$PRODUCT"| grep -Fwqi -e "Product Name: TRUENAS-M50-HA"; then
#
#
echo "TrueNAS M50 Specific valadation" >> swqc-tmp/swqc-output.txt
#
#
# Software Validation of x16 NTB
#
pciconf -lvcb ntb_hw0 | egrep 'PLX|8732|x16\(x16\) speed 8.0\(8.0\)' > swqc-tmp/ntb_hw0.txt
pciconf -lvcb ntb_hw0 | egrep 'PLX|8732|x16\(x16\) speed 8.0\(8.0\)'  >> swqc-tmp/swqc-output.txt
#
#
NTBHW0=$(cat swqc-tmp/ntb_hw0.txt)
#
#Ensure that the following 3 lines are returned by command:
#
# vendor     = 'PLX Technology, Inc.'
# device     = 'PEX 8732 32-lane, 8-Port PCI Express Gen 3 (8.0 GT/s) Switch'
# link x16(x16) speed 8.0(8.0) ASPM disabled(L0s/L1)
#
#
#  check the connection between both controllers NTB:
#  
#
grep ntb_hw /var/log/messages | grep "ntb_hw0: Link is up (PCIe 3.x / x16)" > swqc-tmp/ntb_hw0-link-status.txt # Note:if Single node controller result will be blank
grep ntb_hw /var/log/messages | grep "ntb_hw0: Link is up (PCIe 3.x / x16)" >> swqc-tmp/swqc-output.txt  # Note:if Single node controller result will be blank
#
#
NTBHW0linkstatus=$(cat swqc-tmp/ntb_hw0-link-status.txt)
#
# Ensure that "Link is up" message is returned
#
#
# NTB Window Size
#
pciconf -lvcb ntb_hw0 |egrep "bar.*\[18]"|cut -w -f 12-13 >> swqc-tmp/swqc-output.txt
pciconf -lvcb ntb_hw0 |egrep "bar.*\[18]"|cut -w -f 12-13 > swqc/ntb_hw0_windowsize.txt
#
#
NTBWINDOWSIZE=$(cat swqc/ntb_hw0_windowsize.txt)
#
#
# Size should be size    274877906944,
#
echo "===============================" >> swqc-tmp/swqc-output.txt
#
#
# “Cub” SAS Expander
# 
# 
# 
sesutil map  -u/dev/ses2 |grep LSISAS35 >> swqc-tmp/swqc-output.txt
sesutil map  -u/dev/ses2 |grep LSISAS35 > swqc-tmp/cubsas.txt
#
#
CUBSAS=$(cat swqc-tmp/cubsas.txt)
#
#
# Ensure the following is returned  Description: H24R-3X.R2D (LSISAS35Exp) 
# 
# 
#
echo "===============================" >> swqc-tmp/swqc-output.txt
#
echo "Software Validation of Memory for for TrueNAS M50" >> swqc-tmp/swqc-output.txt
echo "Software Validation of Memory for for TrueNAS M50" >> swqc-tmp/parts-list.txt
#
#
dmidecode -t memory |grep Part|grep HMA84GR7AFR4N-VK|wc -l >> swqc-tmp/swqc-output.txt
dmidecode -t memory |grep Part|grep HMA84GR7AFR4N-VK|wc -l > swqc-tmp/m50_memory_count.txt
dmidecode -t memory |grep Part|grep HMA84GR7AFR4N-VK|wc -l >> swqc-tmp/parts-list.txt
#
M50MEMCOUNT=$(cat swqc-tmp/m50_memory_count.txt) 
#
#
# Validate the output is 8 as that is the number of 34GB RDimms installed
#
#
# 
#
dmidecode -t memory|grep "^[[:blank:]]Locator:\|Part"|grep -B1 HMA84GR7AFR4N-VK |grep Locator >> swqc-tmp/swqc-output.txt
dmidecode -t memory|grep "^[[:blank:]]Locator:\|Part"|grep -B1 HMA84GR7AFR4N-VK |grep Locator > swqc-tmp/m50-ram-slot-check.txt
#
#
# M50RAMSLOTS=$(cat swqc-tmp/m50-ram-slot-check.txt)
#
# Valadate that the ram is in the correct solts The ram should be in slots A1,B1,D1,E1 on each processor
#
#
#
echo "===============================" >> swqc-tmp/swqc-output.txt
#
#
echo "Software Validation of NVDIMMs for M50" >> swqc-tmp/swqc-output.txt
echo "Software Validation of NVDIMMs for M50" >> swqc-tmp/parts-list.txt
#
#
dmidecode -t memory |grep Part|grep 18ASF2G72PF12G9WP1AB|wc -l >> swqc-tmp/swqc-output.txt
dmidecode -t memory |grep Part|grep 18ASF2G72PF12G9WP1AB|wc -l > swqc-tmp/m50-nvdimm-valadation.txt
dmidecode -t memory |grep Part|grep 18ASF2G72PF12G9WP1AB|wc -l >> swqc-tmp/parts-list.txt
#
#
M50NVDIMMVALADATION=$(cat swqc-tmp/m50-nvdimm-valadation.txt)
#
#
echo "===============================" >> swqc-tmp/swqc-output.txt
#
# Validate that both NVDIMMs setup to sync across NTB 
#
#
dmesg |grep 'NTB PMEM syncer'  >> swqc-tmp/swqc-output.txt
dmesg |grep 'NTB PMEM syncer' > swqc-tmp/nvdimm-sync-ntb.txt
#
#
M50NBDIMMSYNC=$(cat swqc-tmp/nvdimm-sync-ntb.txt)
#
# If only one PMEM syncer appears, you may be missing the required loader tunables that enable dual PMEM.
# If no NTB syncers appear, then there may be a serious configuration issue and the issue must be investigated and resolved
#
#
echo "===============================" >> swqc-tmp/swqc-output.txt
#
#
# Ensure that the NVDIMM is in the correct slots
#
dmidecode -t memory|grep "^[[:blank:]]Locator:\|Part"|grep -B1 18ASF2G72PF12G9WP1AB|grep Locator >> swqc-tmp/swqc-output.txt
dmidecode -t memory|grep "^[[:blank:]]Locator:\|Part"|grep -B1 18ASF2G72PF12G9WP1AB|grep Locator > swqc-tm-/M50-nvdimm-slot-check.txt
#
#
M50NVDIMMSLOTS=$(cat swqc-tm-/M50-nvdimm-slot-check.txt)
#
# Note: The ram should be in slots A2 on the first processor P1
#
#
#
echo "===============================" >> swqc-tmp/swqc-output.txt
#
#
# M50 Fan valadation
#
#
ipmitool sensor list | egrep "FAN[34AB]" | cut -d\| -f1-3  >> swqc-tmp/swqc-output.txt
ipmitool sensor list | egrep "FAN[34AB]" | cut -d\| -f1-3 > swqc-tmp/M50-FAN-RPM-CHECK.txt
#
M50FANRPM=$(cat swqc-tmp/M50-FAN-RPM-CHECK.txt)
#
#
#Validate the output shows FAN3 as na
#
#
#
echo "===============================" >> swqc-tmp/swqc-output.txt
#
#
# Ensure that the M50 Fans are set to standard
#
#
ipmitool raw 0x30 0x45 0x00 >> swqc-tmp/swqc-output.txt
ipmitool raw 0x30 0x45 0x00 > swqc-tmp/m50-fan-Setting-check.txt
#
M50FANSETTINGS=$(cat swqc-tmp/m50-fan-Setting-check.txt)
#
#It should return 00
#
fi
#
#
#
if echo "$PRODUCT"| grep -Fwqi -e "Product Name: TRUENAS-M50-HA" && pciconf -lvcb | grep -oh "\w*X722\w*"| grep -Fwqi -e x722; then
echo "On Board nic card" >> swqc-tmp/swqc-output.txt
echo  "On Board nic card" >> swqc-tmp/$SERIAL-diffme.txt
echo  "On Board nic card" >> swqc-tmp/$SERIAL-part-count.txt
#
pciconf -lvcb | grep -i X722 | wc -l > swqc-tmp/M50-add-on-nic-count.txt
pciconf -lvcb | grep -i X722 | wc -l  >> swqc-tmp/$SERIAL-part-count.txt
pciconf -lvcb | grep -i X722 | wc -l  >> swqc-tmp/M50-25GB-nic-list-part.txt
pciconf -lvcb | grep -i X722 | wc -l  >> swqc-tmp/$SERIAL-diffme.txt
pciconf -lvcb | grep -i X722 | wc -l >> swqc-tmp/swqc-output.txt
#
#
fi
#
#
#
#
if echo "$PRODUCT"| grep -Fwqi -e "Product Name: TRUENAS-M50-HA" && pciconf -lvcb | grep -oh "\w*T6225-SO-CR\w*"| grep -Fwqi -e T6225-SO-CR; then
echo "Add on nic card" >> swqc-tmp/swqc-output.txt
echo "Add on nic card" >> swqc-tmp/$SERIAL-diffme.txt
echo "Add on nic card" >> swqc-tmp/$SERIAL-part-count.txt
#
pciconf -lvcb | grep -i T6225-SO-CR | wc -l > swqc-tmp/M50-add-on-nic-count.txt
pciconf -lvcb | grep -i T6225-SO-CR | wc -l  >> swqc-tmp/$SERIAL-part-count.txt
pciconf -lvcb | grep -i T6225-SO-CR | wc -l  >> swqc-tmp/M50-25GB-nic-list-part.txt
pciconf -lvcb | grep -i T6225-SO-CR | wc -l  >> swqc-tmp/$SERIAL-diffme.txt
pciconf -lvcb | grep -i T6225-SO-CR | wc -l >> swqc-tmp/swqc-output.txt
#
#
fi
#
#
#
if echo "$PRODUCT"| grep -Fwqi -e "Product Name: TRUENAS-M50-HA" && pciconf -lvcb | grep -oh "\w*T62100-LP-CR\w*"| grep -Fwqi -e T62100-LP-CR; then
echo "Add on nic card" >> swqc-tmp/swqc-output.txt
echo "Add on nic card" >> swqc-tmp/$SERIAL-diffme.txt
echo "Add on nic card" >> swqc-tmp/$SERIAL-part-count.txt
#
pciconf -lvcb | grep -i T62100-LP-CR | wc -l > swqc-tmp/M50-add-on-nic-count.txt
pciconf -lvcb | grep -i T62100-LP-CR | wc -l  >> swqc-tmp/$SERIAL-part-count.txt
pciconf -lvcb | grep -i T62100-LP-CR| wc -l  >> swqc-tmp/$SERIAL-diffme.txt
pciconf -lvcb | grep -i T62100-LP-CR| wc -l >> swqc-tmp/swqc-output.txt
#
#
fi
#
#
#
if echo "$PRODUCT"| grep -Fwqi -e "Product Name: TRUENAS-M50-HA" && pciconf -lvcb | grep -oh "\w*X710\w*"| grep -Fwqi -e X71-10; then
echo "Add on nic card" >> swqc-tmp/swqc-output.txt
echo "Add on nic card" >> swqc-tmp/$SERIAL-diffme.txt
echo "Add on nic card" >> swqc-tmp/$SERIAL-part-count.txt
#
pciconf -lvcb | grep -i X710 | wc -l > swqc-tmp/M50-add-on-nic-count.txt
pciconf -lvcb | grep -i X710  | wc -l  >> swqc-tmp/$SERIAL-part-count.txt
pciconf -lvcb | grep -i X710 >> swqc-tmp/M50-add-on-nic-list.txt
pciconf -lvcb | grep -i X710 | wc -l  >> swqc-tmp/$SERIAL-diffme.txt
pciconf -lvcb | grep -i X710 | wc -l >> swqc-tmp/swqc-output.txt
#
#
fi
#
#
#
#
#
#
if echo "$PRODUCT"| grep -Fwqi -e "Product Name: TRUENAS-M50-HA" && ifconfig -va | grep -oh "\w*SM10G-SR\w*"| grep -Fwqi -e SM10G-SR; then
echo "10G SFP Count" >> swqc-tmp/swqc-output.txt
echo "10G SFP Count" >> swqc-tmp/$SERIAL-diffme.txt
echo "10G SFP Count" >> swqc-tmp/$SERIAL-part-count.txt
#
ifconfig -va | grep -i SM10G-SR| wc -l > swqc-tmp/M50-10G-SFP-count.txt
ifconfig -va | grep -i SM10G-SR > swqc-tmp/M50-10G-SFP-list.txt
ifconfig -va | grep -i SM10G-SR | wc -l  >> swqc-tmp/$SERIAL-part-count.txt
ifconfig -va | grep -i SM10G-SR | wc -l >> swqc-tmp/$SERIAL-diffme.txt
ifconfig -va | grep -i SM10G-SR | wc -l >> swqc-tmp/swqc-output.txt
#
#
fi
#
#
#
if echo "$PRODUCT"| grep -Fwqi -e "Product Name: TRUENAS-M50-HA" && ifconfig -va | grep -oh "\w*25GBASE-SR\w*"| grep -Fwqi -e 25GBASE-SR; then
echo "25G SFP Count" >> swqc-tmp/swqc-output.txt
echo "25G SFP Count" >> swqc-tmp/$SERIAL-diffme.txt
echo "25G SFP Count" >> swqc-tmp/$SERIAL-part-count.txt
#
ifconfig -va | grep -i 25GBASE-SR| wc -l > swqc-tmp/M50-25G-SFP-count.txt
ifconfig -va | grep -i 25GBASE-SR > swqc-tmp/M50-25G-SFP-list.txt
ifconfig -va | grep -i 25GBASE-SR | wc -l  >> swqc-tmp/$SERIAL-part-count.txt
ifconfig -va | grep -i 25GBASE-SR | wc -l >> swqc-tmp/$SERIAL-diffme.txt
ifconfig -va | grep -i 25GBASE-SR | wc -l >> swqc-tmp/swqc-output.txt
#
#
fi
#
#
#
if echo "$PRODUCT"| grep -Fwqi -e "Product Name: TRUENAS-M50-HA" && ifconfig -va | grep -oh "\w*QSFP-SR4-40G\w*"| grep -Fwqi -e QSFP-SR4-40G; then
echo "40G SFP Count" >> swqc-tmp/swqc-output.txt
echo "40G SFP Count" >> swqc-tmp/$SERIAL-diffme.txt
echo "40G SFP Count" >> swqc-tmp/$SERIAL-part-count.txt
#
ifconfig -va | grep -i QSFP-SR4-40G | wc -l > swqc-tmp/M50-40G-SFP-count.txt
ifconfig -va | grep -i QSFP-SR4-40G > swqc-tmp/M50-40G-SFP-list.txt
ifconfig -va | grep -i QSFP-SR4-40G | wc -l  >> swqc-tmp/$SERIAL-part-count.txt
ifconfig -va | grep -i QSFP-SR4-40G | wc -l >> swqc-tmp/$SERIAL-diffme.txt
ifconfig -va | grep -i QSFP-SR4-40G | wc -l >> swqc-tmp/swqc-output.txt
#
#
fi
#
#
if echo "$PRODUCT"| grep -Fwqi -e "Product Name: TRUENAS-M50-HA"; then
#
echo "TrueNAS M40 Fan valadation" >> swqc-tmp/$SERIAL-diffme.txt
#
#
ipmitool sensor list | grep -Ei "FAN[34AB]" | cut -d\| -f1-3 >> swqc-tmp/$SERIAL-diffme.txt
#
#
fi
#
#
#
#
if echo "$PRODUCT"| grep -Fwqi -e "Product Name: TRUENAS-M50-HA" && ipmitool raw 0x30 0x45 0x00 | grep -oh "\w*00\w*"| grep -Fwqi -e 00; then
#
echo "FAN Speed " >> swqc-tmp/$SERIAL-diffme.txt
#
ipmitool raw 0x30 0x45 0x00 > swqc-tmp/M50-fanspeed-txt
#
M50FANSPEED=$(cat swqc-tmp/M50-fanspeed-txt) 
#
echo "Correctly showing as $M40FANSPEED" >> swqc-tmp/$SERIAL-diffme.txt
#
#
elif echo "$PRODUCT"| grep -Eqi "Product Name: TRUENAS-M50-HA"  && ipmitool raw 0x30 0x45 0x00 | grep -oh "\w*00*" != 00; then
#
echo "FAN Speed " >> swqc-tmp/$SERIAL-diffme.txt
#
M50FANSPEED=$(cat swqc-tmp/M50-fanspeed-txt) 
#
echo "showing as $M50FANSPEED it should be 00 ">> swqc-tmp/$SERIAL-diffme.txt
#
#
fi
#
#
#
#
#
#Bios for TRUENAS-M50 should be 3.3.V6
#
#
if echo "$PRODUCT"| grep -Fwqi -e "Product Name: TRUENAS-M50-HA" && echo "$BIOVER" | grep -oh "\w*3.3av3\w*"| grep -Fwqi -e 3.3av3; then
#
#
echo "bios version" >> swqc-tmp/swqc-output.txt
echo "bios version" >> swqc-tmp/$SERIAL-diffme.txt
echo "bios version" >> swqc-tmp/$SERIAL-part-count.txt
#
echo "Bios version for TRUENAS-M50 is correctly showing as  3.3.av3"  >> swqc-tmp/swqc-output.txt
echo "Bios version for TRUENAS-M50 is correctly showing as  3.3.av3"  > swqc-tmp/M50-bios.txt
echo "Bios version for TRUENAS-M50 is correctly showing as  3.3.av3"  >> swqc-tmp/$SERIAL-diffme.txt
echo "Bios version for TRUENAS-M50 is correctly showing as  3.3.av3"  >> swqc-tmp/$SERIAL-part-count.txt
echo "Bios Version" >> swqc-tmp/$SERIAL-PorF.txt  
echo "pass" >> swqc-tmp/$SERIAL-PorF.txt 
#
elif echo "$PRODUCT"| grep -Fwqi -e 'Product Name: TRUENAS-M50-HA' && echo "$BIOVER" | grep -oh "\w*3.3av3\w*" != 3.3av3; then
#
echo "bios version" >> swqc-tmp/$SERIAL-diffme.txt
echo "bios version" >> swqc-tmp/$SERIAL-part-count.txt
#
echo "Bios version for TRUENAS-M50 is showing as $BIOVER it should be  3.3av3" >> swqc-tmp/swqc-output.txt
echo "Bios version for TRUENAS-M50 is showing as $BIOVER it should be  3.3av3" > swqc-tmp/M50-bios.txt
echo "Bios version for TRUENAS-M50 is showing as $BIOVER it should be  3.3av3" >> swqc-tmp/warning.txt
echo "Bios version for TRUENAS-M50 is showing as $BIOVER it should be  3.3av3" >> swqc-tmp/$SERIAL-diffme.txt
echo "Bios version for TRUENAS-M50 is showing as $BIOVER it should be  3.3av3" >> wqc-tmp/$SERIAL-part-count.txt
echo "Bios Version" >> swqc-tmp/$SERIAL-PorF.txt  
echo "fail" >> swqc-tmp/$SERIAL-PorF.txt 
#
#
M50BIOV=$(cat swqc-tmp/M50-bios.txt)
#
#
fi
#
#
if echo "$PRODUCT"| grep -Fwqi -e "Product Name: TRUENAS-M50-HA" && echo "$BMCINFO" | grep -oh "\w*6.73\w*"| grep -Fwqi -e 6.73; then
#
echo "BMC firmware" >> swqc-tmp/$SERIAL-diffme.txt
echo "BMC firmware" >> swqc-tmp/$SERIAL-part-count.txt
#
echo "BMC Firmware for TRUENAS-M50 should be 6.73"  >> swqc-tmp/swqc-output.txt
#
echo "BMC Firmware for TRUENAS-M50 should be 6.73"   >> swqc-tmp/$SERIAL-diffme.txt
echo "BMC Firmware for TRUENAS-M50 should be 6.73"  >> swqc-tmp/$SERIAL-part-count.txt
#
echo "BMC firmware for TRUENAS-M50 is correctly showing as $BMCINFO it should be  6.73" >> swqc-tmp/swqc-output.txt
echo "BMC firmware for TRUENAS-M50 is correctly showing as $BMCINFO it should be  6.73" > swqc-tmp/M50-bmc.txt
echo "BMC Firmware" >> swqc-tmp/$SERIAL-PorF.txt  
echo "fail" >> swqc-tmp/$SERIAL-PorF.txt 
#
elif echo "$PRODUCT"| grep -Fwqi -e "Product Name: TRUENAS-M50-HA" && echo "$BMCINFO" | grep -oh "\w*6.73\w*" != 6.73; then
#
echo "Bios version for TRUENAS-M50 is showing as $BMCINFO it should be  6.73" >> swqc-tmp/swqc-output.txt
echo "Bios version for TRUENAS-M50 is showing as $BMCINFO it should be  6.73" > swqc-tmp/M50-bmc.txt
echo "Bios version for TRUENAS-M50 is showing as $BMCINFO it should be  6.73" >> swqc-tmp/warning.txt
echo "BMC Firmware" >> swqc-tmp/$SERIAL-PorF.txt  
echo "fail" >> swqc-tmp/$SERIAL-PorF.txt 
#
#
#
M50BMC=$(cat swqc-tmp/M50-bmc.txt)
#
#
fi
#
if echo "$PRODUCT" | grep -Fwqi -e "Product Name: TRUENAS-M50-HA" ; then
#
echo "End of TRUENAS-M50-HA valadation" >> swqc-tmp/swqc-output.txt
#
fi 
#
#
echo "===============================" >> swqc-tmp/swqc-output.txt
###################################################################
#
#
#
#Bios for TRUENAS-M50 should be 3.3.V6
#
#
if echo "$PRODUCT"| grep -Fwqi -e "Product Name: TRUENAS-M50-S" && echo "$BIOVER" | grep -oh "\w*3.3av3\w*"| grep -Fwqi -e 3.3av3; then
#
#
echo "Checking TRUENAS-M50 bios version it should be 3.3.av3"
#
echo "Bios version for TRUENAS-M50 is correctly showing as  3.3.av3"  >> swqc-tmp/swqc-output.txt
echo "Bios version for TRUENAS-M50 is correctly showing as  3.3.av3"  > swqc-tmp/M50-bios.txt
echo "Bios Version" >> swqc-tmp/$SERIAL-PorF.txt  
echo "pass" >> swqc-tmp/$SERIAL-PorF.txt 
#
elif echo "$PRODUCT"| grep -Fwqi -e 'Product Name: TRUENAS-M50-S' && echo "$BIOVER" | grep -oh "\w*3.3av3\w*" != 3.3av3; then
#
echo "Bios version for TRUENAS-M50 is showing as $BIOVER it should be  3.3av3" >> swqc-tmp/swqc-output.txt
echo "Bios version for TRUENAS-M50 is showing as $BIOVER it should be  3.3av3" > swqc-tmp/M50-bios.txt
echo "Bios version for TRUENAS-M50 is showing as $BIOVER it should be  3.3av3" >> swqc-tmp/warning.txt
echo "Bios Version" >> swqc-tmp/$SERIAL-PorF.txt  
echo "fail" >> swqc-tmp/$SERIAL-PorF.txt 
#
#
M50BIOV=$(cat swqc-tmp/M50-bios.txt)
#
#
fi
#
#
if echo "$PRODUCT"| grep -Fwqi -e "Product Name: TRUENAS-M50-S" && echo "$BMCINFO" | grep -oh "\w*6.73\w*"| grep -Fwqi -e 6.73; then
#
echo "BMC Firmware for TRUENAS-M50 should be 6.73"  >> swqc-tmp/swqc-output.txt
#
echo "BMC Firmware for TRUENAS-M50 should be 6.73" 
#
echo "BMC firmware for TRUENAS-M50 is correctly showing as $BMCINFO it should be  6.73" >> swqc-tmp/swqc-output.txt
echo "BMC firmware for TRUENAS-M50 is correctly showing as $BMCINFO it should be  6.73" > swqc-tmp/M50-bmc.txt
echo "BMC Firmware" >> swqc-tmp/$SERIAL-PorF.txt  
echo "fail" >> swqc-tmp/$SERIAL-PorF.txt 
#
elif echo "$PRODUCT"| grep -Fwqi -e "Product Name: TRUENAS-M50-S" && echo "$BMCINFO" | grep -oh "\w*6.73\w*" != 6.73; then
#
echo "BMC Firmware for TRUENAS-M50 is showing as $BMCINFO it should be  6.73" >> swqc-tmp/swqc-output.txt
echo "BMC Firmware for TRUENAS-M50 is showing as $BMCINFO it should be  6.73" > swqc-tmp/M50-bmc.txt
echo "BMC Firmware for TRUENAS-M50 is showing as $BMCINFO it should be  6.73" >> swqc-tmp/warning.txt
echo "BMC Firmware" >> swqc-tmp/$SERIAL-PorF.txt  
echo "fail" >> swqc-tmp/$SERIAL-PorF.txt 
#
#
#
M50BMC=$(cat swqc-tmp/M50-bmc.txt)
#
#
fi
#
#
#
#
#
#
#Bios for TRUENAS-M50 should be 3.3.V6
#
#
if echo "$PRODUCT"| grep -Fwqi -e "Product Name: TRUENAS-M50-S" && echo "$BIOVER" | grep -oh "\w*3.3av3\w*"| grep -Fwqi -e 3.3av3; then
#
#
echo "Checking TRUENAS-M50 bios version it should be 3.3.av3"
#
echo "Bios version for TRUENAS-M50 is correctly showing as  3.3.av3"  >> swqc-tmp/swqc-output.txt
echo "Bios version for TRUENAS-M50 is correctly showing as  3.3.av3"  > swqc-tmp/M50-bios.txt
echo "Bios Version" >> swqc-tmp/$SERIAL-PorF.txt  
echo "pass" >> swqc-tmp/$SERIAL-PorF.txt 
#
elif echo "$PRODUCT"| grep -Fwqi -e 'Product Name: TRUENAS-M50-S' && echo "$BIOVER" | grep -oh "\w*3.3av3\w*" != 3.3av3; then
#
echo "Bios version for TRUENAS-M50 is showing as $BIOVER it should be  3.3av3" >> swqc-tmp/swqc-output.txt
echo "Bios version for TRUENAS-M50 is showing as $BIOVER it should be  3.3av3" > swqc-tmp/M50-bios.txt
echo "Bios version for TRUENAS-M50 is showing as $BIOVER it should be  3.3av3" >> swqc-tmp/warning.txt
echo "Bios Version" >> swqc-tmp/$SERIAL-PorF.txt  
echo "fail" >> swqc-tmp/$SERIAL-PorF.txt 
#
#
M50BIOV=$(cat swqc-tmp/M50-bios.txt)
#
#
fi
#
#
if echo "$PRODUCT"| grep -Fwqi -e "Product Name: TRUENAS-M50-S" && echo "$BMCINFO" | grep -oh "\w*6.73\w*"| grep -Fwqi -e 6.73; then
#
echo "BMC Firmware for TRUENAS-M50 should be 6.73"  >> swqc-tmp/swqc-output.txt
#
echo "BMC Firmware for TRUENAS-M50 should be 6.73" 
#
echo "BMC firmware for TRUENAS-M50 is correctly showing as $BMCINFO it should be  6.73" >> swqc-tmp/swqc-output.txt
echo "BMC firmware for TRUENAS-M50 is correctly showing as $BMCINFO it should be  6.73" > swqc-tmp/M50-bmc.txt
echo "BMC Firmware" >> swqc-tmp/$SERIAL-PorF.txt  
echo "pass" >> swqc-tmp/$SERIAL-PorF.txt 
#
elif echo "$PRODUCT"| grep -Fwqi -e "Product Name: TRUENAS-M50-S" && echo "$BMCINFO" | grep -oh "\w*6.73\w*" != 6.73; then
#
echo "Bios version for TRUENAS-M50 is showing as $BMCINFO it should be  6.73" >> swqc-tmp/swqc-output.txt
echo "Bios version for TRUENAS-M50 is showing as $BMCINFO it should be  6.73" > swqc-tmp/M50-bmc.txt
echo "Bios version for TRUENAS-M50 is showing as $BMCINFO it should be  6.73" >> swqc-tmp/warning.txt
echo "BMC Firmware" >> swqc-tmp/$SERIAL-PorF.txt  
echo "fail" >> swqc-tmp/$SERIAL-PorF.txt 
#
#
#
M50BMC=$(cat swqc-tmp/M50-bmc.txt)
#
#
fi
#
#
#
#
echo " TRUENAS-M50-S Valadation"
echo " TRUENAS-M50-S Valadation" >> swqc-tmp/swqc-output.txt
#
# Software Validation of x16 NTB
#
pciconf -lvcb ntb_hw0 | egrep 'PLX|8732|x16\(x16\) speed 8.0\(8.0\)' > swqc-tmp/ntb_hw0.txt
pciconf -lvcb ntb_hw0 | egrep 'PLX|8732|x16\(x16\) speed 8.0\(8.0\)'  >> swqc-tmp/swqc-output.txt
#
#
NTBHW0=$(cat swqc-tmp/ntb_hw0.txt)
#
#Ensure that the following 3 lines are returned by command:
#
#vendor     = 'PLX Technology, Inc.'
#device     = 'PEX 8732 32-lane, 8-Port PCI Express Gen 3 (8.0 GT/s'
#
#
#
#check the connection between both controllers NTB:
#  
#
grep ntb_hw /var/log/messages | grep "ntb_hw0: Link is up (PCIe 3.x / x16)" > swqc-tmp/ntb_hw0-link-status.txt # Note:if Single node controller result will be blank
grep ntb_hw /var/log/messages | grep "ntb_hw0: Link is up (PCIe 3.x / x16)" >> swqc-tmp/swqc-output.txt  # Note:if Single node controller result will be blank
#
#
NTBHW0linkstatus=$(cat swqc-tmp/ntb_hw0-link-status.txt)
#
# Ensure that "Link is up" message is returned
#
#
# NTB Window Size
#
pciconf -lvcb ntb_hw0 |egrep "bar.*\[18]"|cut -w -f 12-13 >> swqc-tmp/swqc-output.txt
pciconf -lvcb ntb_hw0 |egrep "bar.*\[18]"|cut -w -f 12-13 > swqc/ntb_hw0_windowsize.txt
#
#
NTBWINDOWSIZE=$(cat swqc/ntb_hw0_windowsize.txt)
#
#
# Size should be size    274877906944,
#
echo "===============================" >> swqc-tmp/swqc-output.txt
#
#
# “Cub” SAS Expander
# 
# 
# 
sesutil map  -u/dev/ses2 |grep LSISAS35 >> swqc-tmp/swqc-output.txt
sesutil map  -u/dev/ses2 |grep LSISAS35 > swqc-tmp/cubsas.txt
#
#
CUBSAS=$(cat swqc-tmp/cubsas.txt)
#
#
# Ensure the following is returned  Description: H24R-3X.R2D (LSISAS35Exp) 
#
echo "===============================" >> swqc-tmp/swqc-output.txt
#
echo "Software Validation of Memory for for TrueNAS M50" >> swqc-tmp/swqc-output.txt
echo "Software Validation of Memory for for TrueNAS M50" >> swqc-tmp/parts-list.txt
#
#
dmidecode -t memory |grep Part|grep HMA84GR7AFR4N-VK|wc -l >> swqc-tmp/swqc-output.txt
dmidecode -t memory |grep Part|grep HMA84GR7AFR4N-VK|wc -l > swqc-tmp/m50_memory_count.txt
dmidecode -t memory |grep Part|grep HMA84GR7AFR4N-VK|wc -l >> swqc-tmp/parts-list.txt
#
M50MEMCOUNT=$(cat swqc-tmp/m50_memory_count.txt) 
#
#
# Validate the output is 8 as that is the number of 34GB RDimms installed
#
#
# 
#
dmidecode -t memory|grep "^[[:blank:]]Locator:\|Part"|grep -B1 HMA84GR7AFR4N-VK |grep Locator >> swqc-tmp/swqc-output.txt
dmidecode -t memory|grep "^[[:blank:]]Locator:\|Part"|grep -B1 HMA84GR7AFR4N-VK |grep Locator > swqc-tmp/m50-ram-slot-check.txt
#
#
# M50RAMSLOTS=$(cat swqc-tmp/m50-ram-slot-check.txt)
#
# Valadate that the ram is in the correct solts The ram should be in slots A1,B1,D1,E1 on each processor
#
#
#
echo "===============================" >> swqc-tmp/swqc-output.txt
#
#
echo "Software Validation of NVDIMMs for M50" >> swqc-tmp/swqc-output.txt
echo "Software Validation of NVDIMMs for M50" >> swqc-tmp/parts-list.txt
#
#
dmidecode -t memory |grep Part|grep 18ASF2G72PF12G9WP1AB|wc -l >> swqc-tmp/swqc-output.txt
dmidecode -t memory |grep Part|grep 18ASF2G72PF12G9WP1AB|wc -l > swqc-tmp/m50-nvdimm-valadation.txt
dmidecode -t memory |grep Part|grep 18ASF2G72PF12G9WP1AB|wc -l >> swqc-tmp/parts-list.txt
#
#
M50NVDIMMVALADATION=$(cat swqc-tmp/m50-nvdimm-valadation.txt)
#
#
echo "===============================" >> swqc-tmp/swqc-output.txt
#
# Validate that both NVDIMMs setup to sync across NTB 
#
#
dmesg |grep 'NTB PMEM syncer'  >> swqc-tmp/swqc-output.txt
dmesg |grep 'NTB PMEM syncer' > swqc-tmp/nvdimm-sync-ntb.txt
#
#
M50NBDIMMSYNC=$(cat swqc-tmp/nvdimm-sync-ntb.txt)
#
# If only one PMEM syncer appears, you may be missing the required loader tunables that enable dual PMEM.
# If no NTB syncers appear, then there may be a serious configuration issue and the issue must be investigated and resolved
#
#
echo "===============================" >> swqc-tmp/swqc-output.txt
#
#
# Ensure that the NVDIMM is in the correct slots
#
dmidecode -t memory|grep "^[[:blank:]]Locator:\|Part"|grep -B1 18ASF2G72PF12G9WP1AB|grep Locator >> swqc-tmp/swqc-output.txt
dmidecode -t memory|grep "^[[:blank:]]Locator:\|Part"|grep -B1 18ASF2G72PF12G9WP1AB|grep Locator > swqc-tm-/M50-nvdimm-slot-check.txt
#
#
M50NVDIMMSLOTS=$(cat swqc-tm-/M50-nvdimm-slot-check.txt)
#
# Note: The ram should be in slots A2 on the first processor P1
#
#
#
echo "===============================" >> swqc-tmp/swqc-output.txt
#
#
# M50 Fan valadation
#
#
ipmitool sensor list | egrep "FAN[34AB]" | cut -d\| -f1-3  >> swqc-tmp/swqc-output.txt
ipmitool sensor list | egrep "FAN[34AB]" | cut -d\| -f1-3 > swqc-tmp/M50-FAN-RPM-CHECK.txt
#
M50FANRPM=$(cat swqc-tmp/M50-FAN-RPM-CHECK.txt)
#
#
#Validate the output shows FAN3 as na
#
#
#
echo "===============================" >> swqc-tmp/swqc-output.txt
#
#
# Ensure that the M50 Fans are set to standard
#
#
ipmitool raw 0x30 0x45 0x00 >> swqc-tmp/swqc-output.txt
ipmitool raw 0x30 0x45 0x00 > swqc-tmp/m50-fan-Setting-check.txt
#
M50FANSETTINGS=$(cat swqc-tmp/m50-fan-Setting-check.txt)
#
#It should return 00
#
echo "End of TRUENAS-M50-S  SWQC Check" >> swqc-tmp/swqc-output.txt
#
#
#
#
#
#
if echo "$PRODUCT"| grep -Fwqi -e "TRUENAS-M50-S"  && pciconf -lvcb | grep -oh "\w*T62100-LP-CR\w*"| grep -Fwqi -e T62100-LP-CR; then
echo "Add on nic card" >> swqc-tmp/swqc-output.txt
echo "Add on nic card" >> swqc-tmp/$SERIAL-diffme.txt
echo "Add on nic card" >> swqc-tmp/$SERIAL-part-count.txt
#
pciconf -lvcb | grep -i T62100-LP-CR | wc -l > swqc-tmp/M50-add-on-nic-count.txt
pciconf -lvcb | grep -i T62100-LP-CR | wc -l  >> swqc-tmp/$SERIAL-part-count.txt
pciconf -lvcb | grep -i T62100-LP-CR| wc -l  >> swqc-tmp/$SERIAL-diffme.txt
pciconf -lvcb | grep -i T62100-LP-CR| wc -l >> swqc-tmp/swqc-output.txt
#
#
fi
#
#
#
#
#
if echo "$PRODUCT"| grep -Fwqi -e "TRUENAS-M50-S"  && ifconfig -va | grep -oh "\w*QSFP-SR4-40G\w*"| grep -Fwqi -e QSFP-SR4-40G; then
echo "40G SFP Count" >> swqc-tmp/swqc-output.txt
echo "40G SFP Count" >> swqc-tmp/$SERIAL-diffme.txt
echo "40G SFP Count" >> swqc-tmp/$SERIAL-part-count.txt
#
ifconfig -va | grep -i QSFP-SR4-40G | wc -l > swqc-tmp/M50-40G-SFP-count.txt
ifconfig -va | grep -i QSFP-SR4-40G > swqc-tmp/M50-40G-SFP-list.txt
ifconfig -va | grep -i QSFP-SR4-40G | wc -l  >> swqc-tmp/$SERIAL-part-count.txt
ifconfig -va | grep -i QSFP-SR4-40G | wc -l >> swqc-tmp/$SERIAL-diffme.txt
ifconfig -va | grep -i QSFP-SR4-40G | wc -l >> swqc-tmp/swqc-output.txt
#
#
fi
###################################################################
#
echo "===============================" >> swqc-tmp/swqc-output.txt
###################################################################
#
if echo "$PRODUCT"|grep -Fwqi -e TRUENAS-X10-S; then
#
echo "TrueNAS X10-HA Specific valadation" >> swqc-tmp/swqc-output.txt
#
#
fi
#
#
# Bios for TRUENAS-X10-S should be 3.6v6
#
if echo "$PRODUCT"| grep -Fwqi -e "TRUENAS-X10-S" && echo "$BIOVER" | grep -oh "\w*IXS.1.00.14\w*"| grep -Fwqi -e IXS.1.00.14; then
#
echo "Bios verison" >> swqc-tmp/$SERIAL-part-count.txt
echo "Bios verison" >> swqc-tmp/$SERIAL-diffme.txt
echo "Bios version for TRUENAS-X10-S is correctly showing as IXS.1.00.14"  >> swqc-tmp/swqc-output.txt
echo "Bios version for TRUENAS-X10-S is correctly showing as IXS.1.00.14"  > swqc-tmp/X10-HA-bios.txt
echo "Bios version for TRUENAS-X10-S is correctly showing as IXS.1.00.14"  >> swqc-tmp/$SERIAL-part-count.txt
echo "Bios version for TRUENAS-X10-S is correctly showing as IXS.1.00.14"  >> swqc-tmp/$SERIAL-diffme.txt
echo "Bios Version" >> swqc-tmp/$SERIAL-PorF.txt  
echo "pass" >> swqc-tmp/$SERIAL-PorF.txt 
#
#
elif echo "$PRODUCT"| grep -Fwqi -e TRUENAS-X10-S && echo "$BIOVER"| grep -oh "\w*IXS.1.00.14\w*" != IXS.1.00.14; then
echo "Bios verison" >> swqc-tmp/$SERIAL-part-count.txt
echo "Bios verison" >> swqc-tmp/$SERIAL-diffme.txt
echo "Bios version for TRUENAS-X10-S is showing as $BIOVER it should be  IXS.1.00.14" >> swqc-tmp/swqc-output.txt
echo "Bios version for TRUENAS-X10-S is showing as $BIOVER it should be  IXS.1.00.14" > swqc-tmp/X10-HA-bios.txt
echo "Bios version for TRUENAS-X10-S is showing as $BIOVER it should be  IXS.1.00.14" >> swqc-tmp/warning.txt
echo "Bios version for TRUENAS-X10-S is showing as $BIOVER it should be  IXS.1.00.14" >> swqc-tmp/$SERIAL-part-count.txt
echo "Bios version for TRUENAS-X10-S is showing as $BIOVER it should be  IXS.1.00.14" >> swqc-tmp/$SERIAL-diffme.txt
echo "Bios Version" >> swqc-tmp/$SERIAL-PorF.txt  
echo "fail" >> swqc-tmp/$SERIAL-PorF.txt 
#
#
X10-HAIOV=$(cat swqc-tmp/X10-HA-bios.txt)
#
fi
#
if echo "$PRODUCT"| grep -Fwqi -e "TRUENAS-X10-S"; then
#
echo "X10-HA Memory Count" >> swqc-tmp/$SERIAL-part-count.txt
echo "X10-HA Memory Count" >> swqc-tmp/$SERIAL-diffme.txt
#
#
dmidecode -t memory |grep Part|grep X4F16QG8BNTDME-7-CA | wc -l >> swqc-tmp/$SERIAL-part-count.txt
dmidecode -t memory |grep Part|grep X4F16QG8BNTDME-7-CA | wc -l >> swqc-tmp/$SERIAL-diffme.txt
#
#
#
fi 
#
#
#
if echo "$PRODUCT"| grep -Fwqi -e "TRUENAS-X10-S" && pciconf -lvcb | grep -oh "\w*I210\w*"| grep -Fwqi -e I210; then
echo "Onboard nic card" >> swqc-tmp/swqc-output.txt
echo "Onboard nic card" >> swqc-tmp/$SERIAL-diffme.txt
echo "Onboard nic card" >> swqc-tmp/$SERIAL-part-count.txt
#
pciconf -lvcb | grep -i I210 | wc -l > swqc-tmp/X10-HA-add-on-nic-count.txt
pciconf -lvcb | grep -i I210 | wc -l  >> swqc-tmp/$SERIAL-part-count.txt
pciconf -lvcb | grep -i I210| wc -l  >> swqc-tmp/$SERIAL-diffme.txt
pciconf -lvcb | grep -i I210 wc -l >> swqc-tmp/swqc-output.txt
#
#
fi
#
#
#
#
if echo "$PRODUCT"| grep -Fwqi -e "TRUENAS-X10-S" && pciconf -lvcb | grep -oh "\w*I350\w*"| grep -Fwqi -e I350; then
echo "Add on nic card" >> swqc-tmp/swqc-output.txt
echo "Add on nic card" >> swqc-tmp/$SERIAL-diffme.txt
echo "Add on nic card" >> swqc-tmp/$SERIAL-part-count.txt
#
pciconf -lvcb | grep -i I350 | wc -l > swqc-tmp/X10-HA-add-on-nic-count.txt
pciconf -lvcb | grep -i I350 | wc -l  >> swqc-tmp/$SERIAL-part-count.txt
pciconf -lvcb | grep -i I350| wc -l  >> swqc-tmp/$SERIAL-diffme.txt
pciconf -lvcb | grep -i I350| wc -l >> swqc-tmp/swqc-output.txt
#
#
fi
#
#
#
#
if echo "$PRODUCT"| grep -Fwqi -e "TRUENAS-X10-S" && pciconf -lvcb | grep -oh "\w*T62100-LP-CR\w*"| grep -Fwqi -e T62100-LP-CR; then
echo "Add on nic card" >> swqc-tmp/swqc-output.txt
echo "Add on nic card" >> swqc-tmp/$SERIAL-diffme.txt
echo "Add on nic card" >> swqc-tmp/$SERIAL-part-count.txt
#
pciconf -lvcb | grep -i T62100-LP-CR | wc -l > swqc-tmp/X10-HA-add-on-nic-count.txt
pciconf -lvcb | grep -i T62100-LP-CR | wc -l  >> swqc-tmp/$SERIAL-part-count.txt
pciconf -lvcb | grep -i T62100-LP-CR| wc -l  >> swqc-tmp/$SERIAL-diffme.txt
pciconf -lvcb | grep -i T62100-LP-CR| wc -l >> swqc-tmp/swqc-output.txt
#
#
fi
#
#
#
#
#
#
if echo "$PRODUCT"|grep -Fwqi -e "TRUENAS-X10-S"  && ifconfig -va | grep -oh "\w*SFP-10GSR-85\w*"| grep -Fwqi -e SFP-10GSR-85; then
echo "10G SFP Count" >> swqc-tmp/swqc-output.txt
echo "10G SFP Count" >> swqc-tmp/$SERIAL-diffme.txt
echo "10G SFP Count" >> swqc-tmp/$SERIAL-part-count.txt
#
ifconfig -va | grep -i SFP-10GSR-85| wc -l > swqc-tmp/X10-HA-10G-SFP-count.txt
ifconfig -va | grep -i SFP-10GSR-85 > swqc-tmp/X10-HA-10G-SFP-list.txt
ifconfig -va | grep -i SFP-10GSR-85 | wc -l  >> swqc-tmp/$SERIAL-part-count.txt
ifconfig -va | grep -i SFP-10GSR-85 | wc -l >> swqc-tmp/$SERIAL-diffme.txt
ifconfig -va | grep -i SFP-10GSR-85 | wc -l >> swqc-tmp/swqc-output.txt
#
#
fi
#
#
#
if echo "$PRODUCT"|grep -Fwqi -e "TRUENAS-X10-S"  && ifconfig -va | grep -oh "\w*SM10G-SR\w*"| grep -Fwqi -e SM10G-SR; then
echo "10G SFP Count" >> swqc-tmp/swqc-output.txt
echo "10G SFP Count" >> swqc-tmp/$SERIAL-diffme.txt
echo "10G SFP Count" >> swqc-tmp/$SERIAL-part-count.txt
#
ifconfig -va | grep -i SM10G-SR| wc -l > swqc-tmp/X10-HA-10G-SFP-count.txt
ifconfig -va | grep -i SM10G-SR > swqc-tmp/X10-HA-10G-SFP-list.txt
ifconfig -va | grep -i SM10G-SR | wc -l  >> swqc-tmp/$SERIAL-part-count.txt
ifconfig -va | grep -i SM10G-SR | wc -l >> swqc-tmp/$SERIAL-diffme.txt
ifconfig -va | grep -i SM10G-SR | wc -l >> swqc-tmp/swqc-output.txt
#
#
fi
#
#
#
if echo "$PRODUCT"|grep -Fwqi -e "TRUENAS-X10-S"  && ifconfig -va | grep -oh "\w*25GBASE-SR\w*"| grep -Fwqi -e 25GBASE-SR; then
echo "25G SFP Count" >> swqc-tmp/swqc-output.txt
echo "25G SFP Count" >> swqc-tmp/$SERIAL-diffme.txt
echo "25G SFP Count" >> swqc-tmp/$SERIAL-part-count.txt
#
ifconfig -va | grep -i 25GBASE-SR| wc -l > swqc-tmp/X10-HA-25G-SFP-count.txt
ifconfig -va | grep -i 25GBASE-SR > swqc-tmp/X10-HA-25G-SFP-list.txt
ifconfig -va | grep -i 25GBASE-SR | wc -l  >> swqc-tmp/$SERIAL-part-count.txt
ifconfig -va | grep -i 25GBASE-SR | wc -l >> swqc-tmp/$SERIAL-diffme.txt
ifconfig -va | grep -i 25GBASE-SR | wc -l >> swqc-tmp/swqc-output.txt
#
#
fi
#
#
#
if echo "$PRODUCT"|grep -Fwqi -e "TRUENAS-X10-S"  && ifconfig -va | grep -oh "\w*QSFP-SR4-40G\w*"| grep -Fwqi -e QSFP-SR4-40G; then
echo "40G SFP Count" >> swqc-tmp/swqc-output.txt
echo "40G SFP Count" >> swqc-tmp/$SERIAL-diffme.txt
echo "40G SFP Count" >> swqc-tmp/$SERIAL-part-count.txt
#
ifconfig -va | grep -i QSFP-SR4-40G | wc -l > swqc-tmp/X10-HA-40G-SFP-count.txt
ifconfig -va | grep -i QSFP-SR4-40G > swqc-tmp/X10-HA-40G-SFP-list.txt
ifconfig -va | grep -i QSFP-SR4-40G | wc -l  >> swqc-tmp/$SERIAL-part-count.txt
ifconfig -va | grep -i QSFP-SR4-40G | wc -l >> swqc-tmp/$SERIAL-diffme.txt
ifconfig -va | grep -i QSFP-SR4-40G | wc -l >> swqc-tmp/swqc-output.txt
#
#
fi
#
#
#
#
#
#
#
#
echo "===============================" >> swqc-tmp/swqc-output.txt
###################################################################
#
if echo "$PRODUCT"|grep -Fwqi -e TRUENAS-X10-HA; then
#
echo "TrueNAS X10-HA Specific valadation" >> swqc-tmp/swqc-output.txt
#
#
fi
#
#
# Bios for TRUENAS-X10-HA should be 3.6v6
#
if echo "$PRODUCT"| grep -Fwqi -e "TRUENAS-X10-HA" && echo "$BIOVER" | grep -oh "\w*IXS.1.00.14\w*"| grep -Fwqi -e IXS.1.00.14; then
#
echo "Bios verison" >> swqc-tmp/$SERIAL-part-count.txt
echo "Bios verison" >> swqc-tmp/$SERIAL-diffme.txt
echo "Bios version for TRUENAS-X10-HA is correctly showing as IXS.1.00.14"  >> swqc-tmp/swqc-output.txt
echo "Bios version for TRUENAS-X10-HA is correctly showing as IXS.1.00.14"  > swqc-tmp/X10-HA-bios.txt
echo "Bios version for TRUENAS-X10-HA is correctly showing as IXS.1.00.14"  >> swqc-tmp/$SERIAL-part-count.txt
echo "Bios version for TRUENAS-X10-HA is correctly showing as IXS.1.00.14"  >> swqc-tmp/$SERIAL-diffme.txt
echo "Bios Version" >> swqc-tmp/$SERIAL-PorF.txt  
echo "pass" >> swqc-tmp/$SERIAL-PorF.txt 
#
#
elif echo "$PRODUCT"| grep -Fwqi -e TRUENAS-X10-HA && echo "$BIOVER"| grep -oh "\w*IXS.1.00.14\w*" != IXS.1.00.14; then
echo "Bios verison" >> swqc-tmp/$SERIAL-part-count.txt
echo "Bios verison" >> swqc-tmp/$SERIAL-diffme.txt
echo "Bios version for TRUENAS-X10-HA is showing as $BIOVER it should be  IXS.1.00.14" >> swqc-tmp/swqc-output.txt
echo "Bios version for TRUENAS-X10-HA is showing as $BIOVER it should be  IXS.1.00.14" > swqc-tmp/X10-HA-bios.txt
echo "Bios version for TRUENAS-X10-HA is showing as $BIOVER it should be  IXS.1.00.14" >> swqc-tmp/warning.txt
echo "Bios version for TRUENAS-X10-HA is showing as $BIOVER it should be  IXS.1.00.14" >> swqc-tmp/$SERIAL-part-count.txt
echo "Bios version for TRUENAS-X10-HA is showing as $BIOVER it should be  IXS.1.00.14" >> swqc-tmp/$SERIAL-diffme.txt
echo "Bios Version" >> swqc-tmp/$SERIAL-PorF.txt  
echo "fail" >> swqc-tmp/$SERIAL-PorF.txt 
#
#
X10-HAIOV=$(cat swqc-tmp/X10-HA-bios.txt)
#
fi
#
if echo "$PRODUCT"| grep -Fwqi -e "TRUENAS-X10-HA"; then
#
echo "X10-HA Memory Count" >> swqc-tmp/$SERIAL-part-count.txt
echo "X10-HA Memory Count" >> swqc-tmp/$SERIAL-diffme.txt
#
#
dmidecode -t memory |grep Part|grep X4F16QG8BNTDME-7-CA | wc -l >> swqc-tmp/$SERIAL-part-count.txt
dmidecode -t memory |grep Part|grep X4F16QG8BNTDME-7-CA | wc -l >> swqc-tmp/$SERIAL-diffme.txt
#
#
#
fi 
#
#
#
if echo "$PRODUCT"| grep -Fwqi -e "TRUENAS-X10-HA" && pciconf -lvcb | grep -oh "\w*I210\w*"| grep -Fwqi -e I210; then
echo "Onboard nic card" >> swqc-tmp/swqc-output.txt
echo "Onboard nic card" >> swqc-tmp/$SERIAL-diffme.txt
echo "Onboard nic card" >> swqc-tmp/$SERIAL-part-count.txt
#
pciconf -lvcb | grep -i I210 | wc -l > swqc-tmp/X10-HA-add-on-nic-count.txt
pciconf -lvcb | grep -i I210 | wc -l  >> swqc-tmp/$SERIAL-part-count.txt
pciconf -lvcb | grep -i I210| wc -l  >> swqc-tmp/$SERIAL-diffme.txt
pciconf -lvcb | grep -i I210 wc -l >> swqc-tmp/swqc-output.txt
#
#
fi
#
#
#
#
if echo "$PRODUCT"| grep -Fwqi -e "TRUENAS-X10-HA" && pciconf -lvcb | grep -oh "\w*I350\w*"| grep -Fwqi -e I350; then
echo "Add on nic card" >> swqc-tmp/swqc-output.txt
echo "Add on nic card" >> swqc-tmp/$SERIAL-diffme.txt
echo "Add on nic card" >> swqc-tmp/$SERIAL-part-count.txt
#
pciconf -lvcb | grep -i I350 | wc -l > swqc-tmp/X10-HA-add-on-nic-count.txt
pciconf -lvcb | grep -i I350 | wc -l  >> swqc-tmp/$SERIAL-part-count.txt
pciconf -lvcb | grep -i I350| wc -l  >> swqc-tmp/$SERIAL-diffme.txt
pciconf -lvcb | grep -i I350| wc -l >> swqc-tmp/swqc-output.txt
#
#
fi
#
#
#
#
if echo "$PRODUCT"| grep -Fwqi -e "TRUENAS-X10-HA" && pciconf -lvcb | grep -oh "\w*T62100-LP-CR\w*"| grep -Fwqi -e T62100-LP-CR; then
echo "Add on nic card" >> swqc-tmp/swqc-output.txt
echo "Add on nic card" >> swqc-tmp/$SERIAL-diffme.txt
echo "Add on nic card" >> swqc-tmp/$SERIAL-part-count.txt
#
pciconf -lvcb | grep -i T62100-LP-CR | wc -l > swqc-tmp/X10-HA-add-on-nic-count.txt
pciconf -lvcb | grep -i T62100-LP-CR | wc -l  >> swqc-tmp/$SERIAL-part-count.txt
pciconf -lvcb | grep -i T62100-LP-CR| wc -l  >> swqc-tmp/$SERIAL-diffme.txt
pciconf -lvcb | grep -i T62100-LP-CR| wc -l >> swqc-tmp/swqc-output.txt
#
#
fi
#
#
#
#
#
#
if echo "$PRODUCT"|grep -Fwqi -e "TRUENAS-X10-HA"  && ifconfig -va | grep -oh "\w*SFP-10GSR-85\w*"| grep -Fwqi -e SFP-10GSR-85; then
echo "10G SFP Count" >> swqc-tmp/swqc-output.txt
echo "10G SFP Count" >> swqc-tmp/$SERIAL-diffme.txt
echo "10G SFP Count" >> swqc-tmp/$SERIAL-part-count.txt
#
ifconfig -va | grep -i SFP-10GSR-85| wc -l > swqc-tmp/X10-HA-10G-SFP-count.txt
ifconfig -va | grep -i SFP-10GSR-85 > swqc-tmp/X10-HA-10G-SFP-list.txt
ifconfig -va | grep -i SFP-10GSR-85 | wc -l  >> swqc-tmp/$SERIAL-part-count.txt
ifconfig -va | grep -i SFP-10GSR-85 | wc -l >> swqc-tmp/$SERIAL-diffme.txt
ifconfig -va | grep -i SFP-10GSR-85 | wc -l >> swqc-tmp/swqc-output.txt
#
#
fi
#
#
#
if echo "$PRODUCT"|grep -Fwqi -e "TRUENAS-X10-HA"  && ifconfig -va | grep -oh "\w*SM10G-SR\w*"| grep -Fwqi -e SM10G-SR; then
echo "10G SFP Count" >> swqc-tmp/swqc-output.txt
echo "10G SFP Count" >> swqc-tmp/$SERIAL-diffme.txt
echo "10G SFP Count" >> swqc-tmp/$SERIAL-part-count.txt
#
ifconfig -va | grep -i SM10G-SR| wc -l > swqc-tmp/X10-HA-10G-SFP-count.txt
ifconfig -va | grep -i SM10G-SR > swqc-tmp/X10-HA-10G-SFP-list.txt
ifconfig -va | grep -i SM10G-SR | wc -l  >> swqc-tmp/$SERIAL-part-count.txt
ifconfig -va | grep -i SM10G-SR | wc -l >> swqc-tmp/$SERIAL-diffme.txt
ifconfig -va | grep -i SM10G-SR | wc -l >> swqc-tmp/swqc-output.txt
#
#
fi
#
#
#
if echo "$PRODUCT"|grep -Fwqi -e "TRUENAS-X10-HA"  && ifconfig -va | grep -oh "\w*25GBASE-SR\w*"| grep -Fwqi -e 25GBASE-SR; then
echo "25G SFP Count" >> swqc-tmp/swqc-output.txt
echo "25G SFP Count" >> swqc-tmp/$SERIAL-diffme.txt
echo "25G SFP Count" >> swqc-tmp/$SERIAL-part-count.txt
#
ifconfig -va | grep -i 25GBASE-SR| wc -l > swqc-tmp/X10-HA-25G-SFP-count.txt
ifconfig -va | grep -i 25GBASE-SR > swqc-tmp/X10-HA-25G-SFP-list.txt
ifconfig -va | grep -i 25GBASE-SR | wc -l  >> swqc-tmp/$SERIAL-part-count.txt
ifconfig -va | grep -i 25GBASE-SR | wc -l >> swqc-tmp/$SERIAL-diffme.txt
ifconfig -va | grep -i 25GBASE-SR | wc -l >> swqc-tmp/swqc-output.txt
#
#
fi
#
#
#
if echo "$PRODUCT"|grep -Fwqi -e "TRUENAS-X10-HA"  && ifconfig -va | grep -oh "\w*QSFP-SR4-40G\w*"| grep -Fwqi -e QSFP-SR4-40G; then
echo "40G SFP Count" >> swqc-tmp/swqc-output.txt
echo "40G SFP Count" >> swqc-tmp/$SERIAL-diffme.txt
echo "40G SFP Count" >> swqc-tmp/$SERIAL-part-count.txt
#
ifconfig -va | grep -i QSFP-SR4-40G | wc -l > swqc-tmp/X10-HA-40G-SFP-count.txt
ifconfig -va | grep -i QSFP-SR4-40G > swqc-tmp/X10-HA-40G-SFP-list.txt
ifconfig -va | grep -i QSFP-SR4-40G | wc -l  >> swqc-tmp/$SERIAL-part-count.txt
ifconfig -va | grep -i QSFP-SR4-40G | wc -l >> swqc-tmp/$SERIAL-diffme.txt
ifconfig -va | grep -i QSFP-SR4-40G | wc -l >> swqc-tmp/swqc-output.txt
#
#
fi
#
#
#
###################################################################
#
	###################################################################
#
if echo "$PRODUCT"|grep -Fwqi -e TRUENAS-X20-S; then
#
echo "TrueNAS X10-HA Specific valadation" >> swqc-tmp/swqc-output.txt
#
#
fi
#
#
# Bios for TRUENAS-X20-S should be 3.6v6
#
if echo "$PRODUCT"| grep -Fwqi -e "TRUENAS-X20-S" && echo "$BIOVER" | grep -oh "\w*IXS.1.00.14\w*"| grep -Fwqi -e IXS.1.00.14; then
#
echo "Bios verison" >> swqc-tmp/$SERIAL-part-count.txt
echo "Bios verison" >> swqc-tmp/$SERIAL-diffme.txt
echo "Bios version for TRUENAS-X20-S is correctly showing as IXS.1.00.14"  >> swqc-tmp/swqc-output.txt
echo "Bios version for TRUENAS-X20-S is correctly showing as IXS.1.00.14"  > swqc-tmp/X10-HA-bios.txt
echo "Bios version for TRUENAS-X20-S is correctly showing as IXS.1.00.14"  >> swqc-tmp/$SERIAL-part-count.txt
echo "Bios version for TRUENAS-X20-S is correctly showing as IXS.1.00.14"  >> swqc-tmp/$SERIAL-diffme.txt
#
#
elif echo "$PRODUCT"| grep -Fwqi -e TRUENAS-X20-S && echo "$BIOVER"| grep -oh "\w*IXS.1.00.14\w*" != IXS.1.00.14; then
echo "Bios verison" >> swqc-tmp/$SERIAL-part-count.txt
echo "Bios verison" >> swqc-tmp/$SERIAL-diffme.txt
echo "Bios version for TRUENAS-X20-S is showing as $BIOVER it should be  IXS.1.00.14" >> swqc-tmp/swqc-output.txt
echo "Bios version for TRUENAS-X20-S is showing as $BIOVER it should be  IXS.1.00.14" > swqc-tmp/X10-HA-bios.txt
echo "Bios version for TRUENAS-X20-S is showing as $BIOVER it should be  IXS.1.00.14" >> swqc-tmp/warning.txt
echo "Bios version for TRUENAS-X20-S is showing as $BIOVER it should be  IXS.1.00.14" >> swqc-tmp/$SERIAL-part-count.txt
echo "Bios version for TRUENAS-X20-S is showing as $BIOVER it should be  IXS.1.00.14" >> swqc-tmp/$SERIAL-diffme.txt
#
#
X10-HAIOV=$(cat swqc-tmp/X10-HA-bios.txt)
#
fi
#
if echo "$PRODUCT"| grep -Fwqi -e "TRUENAS-X20-S"; then
#
echo "X10-HA Memory Count" >> swqc-tmp/$SERIAL-part-count.txt
echo "X10-HA Memory Count" >> swqc-tmp/$SERIAL-diffme.txt
#
#
dmidecode -t memory |grep Part|grep X4F16QG8BNTDME-7-CA | wc -l >> swqc-tmp/$SERIAL-part-count.txt
dmidecode -t memory |grep Part|grep X4F16QG8BNTDME-7-CA | wc -l >> swqc-tmp/$SERIAL-diffme.txt
#
#
#
fi 
#
#
#
if echo "$PRODUCT"| grep -Fwqi -e "TRUENAS-X20-S" && pciconf -lvcb | grep -oh "\w*I210\w*"| grep -Fwqi -e I210; then
echo "Onboard nic card" >> swqc-tmp/swqc-output.txt
echo "Onboard nic card" >> swqc-tmp/$SERIAL-diffme.txt
echo "Onboard nic card" >> swqc-tmp/$SERIAL-part-count.txt
#
pciconf -lvcb | grep -i I210 | wc -l > swqc-tmp/X10-HA-add-on-nic-count.txt
pciconf -lvcb | grep -i I210 | wc -l  >> swqc-tmp/$SERIAL-part-count.txt
pciconf -lvcb | grep -i I210| wc -l  >> swqc-tmp/$SERIAL-diffme.txt
pciconf -lvcb | grep -i I210 wc -l >> swqc-tmp/swqc-output.txt
#
#
fi
#
#
#
#
if echo "$PRODUCT"| grep -Fwqi -e "TRUENAS-X20-S" && pciconf -lvcb | grep -oh "\w*I350\w*"| grep -Fwqi -e I350; then
echo "Add on nic card" >> swqc-tmp/swqc-output.txt
echo "Add on nic card" >> swqc-tmp/$SERIAL-diffme.txt
echo "Add on nic card" >> swqc-tmp/$SERIAL-part-count.txt
#
pciconf -lvcb | grep -i I350 | wc -l > swqc-tmp/X10-HA-add-on-nic-count.txt
pciconf -lvcb | grep -i I350 | wc -l  >> swqc-tmp/$SERIAL-part-count.txt
pciconf -lvcb | grep -i I350| wc -l  >> swqc-tmp/$SERIAL-diffme.txt
pciconf -lvcb | grep -i I350| wc -l >> swqc-tmp/swqc-output.txt
#
#
fi
#
#
#
#
if echo "$PRODUCT"| grep -Fwqi -e "TRUENAS-X20-S" && pciconf -lvcb | grep -oh "\w*T62100-LP-CR\w*"| grep -Fwqi -e T62100-LP-CR; then
echo "Add on nic card" >> swqc-tmp/swqc-output.txt
echo "Add on nic card" >> swqc-tmp/$SERIAL-diffme.txt
echo "Add on nic card" >> swqc-tmp/$SERIAL-part-count.txt
#
pciconf -lvcb | grep -i T62100-LP-CR | wc -l > swqc-tmp/X10-HA-add-on-nic-count.txt
pciconf -lvcb | grep -i T62100-LP-CR | wc -l  >> swqc-tmp/$SERIAL-part-count.txt
pciconf -lvcb | grep -i T62100-LP-CR| wc -l  >> swqc-tmp/$SERIAL-diffme.txt
pciconf -lvcb | grep -i T62100-LP-CR| wc -l >> swqc-tmp/swqc-output.txt
#
#
fi
#
#
#
#
#
#
if echo "$PRODUCT"|grep -Fwqi -e "TRUENAS-X20-S"  && ifconfig -va | grep -oh "\w*SFP-10GSR-85\w*"| grep -Fwqi -e SFP-10GSR-85; then
echo "10G SFP Count" >> swqc-tmp/swqc-output.txt
echo "10G SFP Count" >> swqc-tmp/$SERIAL-diffme.txt
echo "10G SFP Count" >> swqc-tmp/$SERIAL-part-count.txt
#
ifconfig -va | grep -i SFP-10GSR-85| wc -l > swqc-tmp/X10-HA-10G-SFP-count.txt
ifconfig -va | grep -i SFP-10GSR-85 > swqc-tmp/X10-HA-10G-SFP-list.txt
ifconfig -va | grep -i SFP-10GSR-85 | wc -l  >> swqc-tmp/$SERIAL-part-count.txt
ifconfig -va | grep -i SFP-10GSR-85 | wc -l >> swqc-tmp/$SERIAL-diffme.txt
ifconfig -va | grep -i SFP-10GSR-85 | wc -l >> swqc-tmp/swqc-output.txt
#
#
fi
#
#
#
if echo "$PRODUCT"|grep -Fwqi -e "TRUENAS-X20-S"  && ifconfig -va | grep -oh "\w*SM10G-SR\w*"| grep -Fwqi -e SM10G-SR; then
echo "10G SFP Count" >> swqc-tmp/swqc-output.txt
echo "10G SFP Count" >> swqc-tmp/$SERIAL-diffme.txt
echo "10G SFP Count" >> swqc-tmp/$SERIAL-part-count.txt
#
ifconfig -va | grep -i SM10G-SR| wc -l > swqc-tmp/X10-HA-10G-SFP-count.txt
ifconfig -va | grep -i SM10G-SR > swqc-tmp/X10-HA-10G-SFP-list.txt
ifconfig -va | grep -i SM10G-SR | wc -l  >> swqc-tmp/$SERIAL-part-count.txt
ifconfig -va | grep -i SM10G-SR | wc -l >> swqc-tmp/$SERIAL-diffme.txt
ifconfig -va | grep -i SM10G-SR | wc -l >> swqc-tmp/swqc-output.txt
#
#
fi
#
#
#
if echo "$PRODUCT"|grep -Fwqi -e "TRUENAS-X20-S"  && ifconfig -va | grep -oh "\w*25GBASE-SR\w*"| grep -Fwqi -e 25GBASE-SR; then
echo "25G SFP Count" >> swqc-tmp/swqc-output.txt
echo "25G SFP Count" >> swqc-tmp/$SERIAL-diffme.txt
echo "25G SFP Count" >> swqc-tmp/$SERIAL-part-count.txt
#
ifconfig -va | grep -i 25GBASE-SR| wc -l > swqc-tmp/X10-HA-25G-SFP-count.txt
ifconfig -va | grep -i 25GBASE-SR > swqc-tmp/X10-HA-25G-SFP-list.txt
ifconfig -va | grep -i 25GBASE-SR | wc -l  >> swqc-tmp/$SERIAL-part-count.txt
ifconfig -va | grep -i 25GBASE-SR | wc -l >> swqc-tmp/$SERIAL-diffme.txt
ifconfig -va | grep -i 25GBASE-SR | wc -l >> swqc-tmp/swqc-output.txt
#
#
fi
#
#
#
if echo "$PRODUCT"|grep -Fwqi -e "TRUENAS-X20-S"  && ifconfig -va | grep -oh "\w*QSFP-SR4-40G\w*"| grep -Fwqi -e QSFP-SR4-40G; then
echo "40G SFP Count" >> swqc-tmp/swqc-output.txt
echo "40G SFP Count" >> swqc-tmp/$SERIAL-diffme.txt
echo "40G SFP Count" >> swqc-tmp/$SERIAL-part-count.txt
#
ifconfig -va | grep -i QSFP-SR4-40G | wc -l > swqc-tmp/X10-HA-40G-SFP-count.txt
ifconfig -va | grep -i QSFP-SR4-40G > swqc-tmp/X10-HA-40G-SFP-list.txt
ifconfig -va | grep -i QSFP-SR4-40G | wc -l  >> swqc-tmp/$SERIAL-part-count.txt
ifconfig -va | grep -i QSFP-SR4-40G | wc -l >> swqc-tmp/$SERIAL-diffme.txt
ifconfig -va | grep -i QSFP-SR4-40G | wc -l >> swqc-tmp/swqc-output.txt
#
#
fi
#
#
#
#
#
#
#
#
echo "===============================" >> swqc-tmp/swqc-output.txt
###################################################################
#
if echo "$PRODUCT"|grep -Fwqi -e TRUENAS-X20-HA; then
#
echo "TrueNAS X10-HA Specific valadation" >> swqc-tmp/swqc-output.txt
#
#
fi
#
#
# Bios for TRUENAS-X20-HA should be 3.6v6
#
if echo "$PRODUCT"| grep -Fwqi -e "TRUENAS-X20-HA" && echo "$BIOVER" | grep -oh "\w*IXS.1.00.14\w*"| grep -Fwqi -e IXS.1.00.14; then
#
echo "Bios verison" >> swqc-tmp/$SERIAL-part-count.txt
echo "Bios verison" >> swqc-tmp/$SERIAL-diffme.txt
echo "Bios version for TRUENAS-X20-HA is correctly showing as IXS.1.00.14"  >> swqc-tmp/swqc-output.txt
echo "Bios version for TRUENAS-X20-HA is correctly showing as IXS.1.00.14"  > swqc-tmp/X10-HA-bios.txt
echo "Bios version for TRUENAS-X20-HA is correctly showing as IXS.1.00.14"  >> swqc-tmp/$SERIAL-part-count.txt
echo "Bios version for TRUENAS-X20-HA is correctly showing as IXS.1.00.14"  >> swqc-tmp/$SERIAL-diffme.txt
#
#
elif echo "$PRODUCT"| grep -Fwqi -e TRUENAS-X20-HA && echo "$BIOVER"| grep -oh "\w*IXS.1.00.14\w*" != IXS.1.00.14; then
echo "Bios verison" >> swqc-tmp/$SERIAL-part-count.txt
echo "Bios verison" >> swqc-tmp/$SERIAL-diffme.txt
echo "Bios version for TRUENAS-X20-HA is showing as $BIOVER it should be  IXS.1.00.14" >> swqc-tmp/swqc-output.txt
echo "Bios version for TRUENAS-X20-HA is showing as $BIOVER it should be  IXS.1.00.14" > swqc-tmp/X10-HA-bios.txt
echo "Bios version for TRUENAS-X20-HA is showing as $BIOVER it should be  IXS.1.00.14" >> swqc-tmp/warning.txt
echo "Bios version for TRUENAS-X20-HA is showing as $BIOVER it should be  IXS.1.00.14" >> swqc-tmp/$SERIAL-part-count.txt
echo "Bios version for TRUENAS-X20-HA is showing as $BIOVER it should be  IXS.1.00.14" >> swqc-tmp/$SERIAL-diffme.txt
#
#
X10-HAIOV=$(cat swqc-tmp/X10-HA-bios.txt)
#
fi
#
if echo "$PRODUCT"| grep -Fwqi -e "TRUENAS-X20-HA"; then
#
echo "X10-HA Memory Count" >> swqc-tmp/$SERIAL-part-count.txt
echo "X10-HA Memory Count" >> swqc-tmp/$SERIAL-diffme.txt
#
#
dmidecode -t memory |grep Part|grep X4F16QG8BNTDME-7-CA | wc -l >> swqc-tmp/$SERIAL-part-count.txt
dmidecode -t memory |grep Part|grep X4F16QG8BNTDME-7-CA | wc -l >> swqc-tmp/$SERIAL-diffme.txt
#
#
#
fi 
#
#
#
if echo "$PRODUCT"| grep -Fwqi -e "TRUENAS-X20-HA" && pciconf -lvcb | grep -oh "\w*I210\w*"| grep -Fwqi -e I210; then
echo "Onboard nic card" >> swqc-tmp/swqc-output.txt
echo "Onboard nic card" >> swqc-tmp/$SERIAL-diffme.txt
echo "Onboard nic card" >> swqc-tmp/$SERIAL-part-count.txt
#
pciconf -lvcb | grep -i I210 | wc -l > swqc-tmp/X10-HA-add-on-nic-count.txt
pciconf -lvcb | grep -i I210 | wc -l  >> swqc-tmp/$SERIAL-part-count.txt
pciconf -lvcb | grep -i I210| wc -l  >> swqc-tmp/$SERIAL-diffme.txt
pciconf -lvcb | grep -i I210 wc -l >> swqc-tmp/swqc-output.txt
#
#
fi
#
#
#
#
if echo "$PRODUCT"| grep -Fwqi -e "TRUENAS-X20-HA" && pciconf -lvcb | grep -oh "\w*I350\w*"| grep -Fwqi -e I350; then
echo "Add on nic card" >> swqc-tmp/swqc-output.txt
echo "Add on nic card" >> swqc-tmp/$SERIAL-diffme.txt
echo "Add on nic card" >> swqc-tmp/$SERIAL-part-count.txt
#
pciconf -lvcb | grep -i I350 | wc -l > swqc-tmp/X10-HA-add-on-nic-count.txt
pciconf -lvcb | grep -i I350 | wc -l  >> swqc-tmp/$SERIAL-part-count.txt
pciconf -lvcb | grep -i I350| wc -l  >> swqc-tmp/$SERIAL-diffme.txt
pciconf -lvcb | grep -i I350| wc -l >> swqc-tmp/swqc-output.txt
#
#
fi
#
#
#
#
if echo "$PRODUCT"| grep -Fwqi -e "TRUENAS-X20-HA" && pciconf -lvcb | grep -oh "\w*T62100-LP-CR\w*"| grep -Fwqi -e T62100-LP-CR; then
echo "Add on nic card" >> swqc-tmp/swqc-output.txt
echo "Add on nic card" >> swqc-tmp/$SERIAL-diffme.txt
echo "Add on nic card" >> swqc-tmp/$SERIAL-part-count.txt
#
pciconf -lvcb | grep -i T62100-LP-CR | wc -l > swqc-tmp/X10-HA-add-on-nic-count.txt
pciconf -lvcb | grep -i T62100-LP-CR | wc -l  >> swqc-tmp/$SERIAL-part-count.txt
pciconf -lvcb | grep -i T62100-LP-CR| wc -l  >> swqc-tmp/$SERIAL-diffme.txt
pciconf -lvcb | grep -i T62100-LP-CR| wc -l >> swqc-tmp/swqc-output.txt
#
#
fi
#
#
#
#
#
#
if echo "$PRODUCT"|grep -Fwqi -e "TRUENAS-X20-HA"  && ifconfig -va | grep -oh "\w*SFP-10GSR-85\w*"| grep -Fwqi -e SFP-10GSR-85; then
echo "10G SFP Count" >> swqc-tmp/swqc-output.txt
echo "10G SFP Count" >> swqc-tmp/$SERIAL-diffme.txt
echo "10G SFP Count" >> swqc-tmp/$SERIAL-part-count.txt
#
ifconfig -va | grep -i SFP-10GSR-85| wc -l > swqc-tmp/X10-HA-10G-SFP-count.txt
ifconfig -va | grep -i SFP-10GSR-85 > swqc-tmp/X10-HA-10G-SFP-list.txt
ifconfig -va | grep -i SFP-10GSR-85 | wc -l  >> swqc-tmp/$SERIAL-part-count.txt
ifconfig -va | grep -i SFP-10GSR-85 | wc -l >> swqc-tmp/$SERIAL-diffme.txt
ifconfig -va | grep -i SFP-10GSR-85 | wc -l >> swqc-tmp/swqc-output.txt
#
#
fi
#
#
#
if echo "$PRODUCT"|grep -Fwqi -e "TRUENAS-X20-HA"  && ifconfig -va | grep -oh "\w*SM10G-SR\w*"| grep -Fwqi -e SM10G-SR; then
echo "10G SFP Count" >> swqc-tmp/swqc-output.txt
echo "10G SFP Count" >> swqc-tmp/$SERIAL-diffme.txt
echo "10G SFP Count" >> swqc-tmp/$SERIAL-part-count.txt
#
ifconfig -va | grep -i SM10G-SR| wc -l > swqc-tmp/X10-HA-10G-SFP-count.txt
ifconfig -va | grep -i SM10G-SR > swqc-tmp/X10-HA-10G-SFP-list.txt
ifconfig -va | grep -i SM10G-SR | wc -l  >> swqc-tmp/$SERIAL-part-count.txt
ifconfig -va | grep -i SM10G-SR | wc -l >> swqc-tmp/$SERIAL-diffme.txt
ifconfig -va | grep -i SM10G-SR | wc -l >> swqc-tmp/swqc-output.txt
#
#
fi
#
#
#
if echo "$PRODUCT"|grep -Fwqi -e "TRUENAS-X20-HA"  && ifconfig -va | grep -oh "\w*25GBASE-SR\w*"| grep -Fwqi -e 25GBASE-SR; then
echo "25G SFP Count" >> swqc-tmp/swqc-output.txt
echo "25G SFP Count" >> swqc-tmp/$SERIAL-diffme.txt
echo "25G SFP Count" >> swqc-tmp/$SERIAL-part-count.txt
#
ifconfig -va | grep -i 25GBASE-SR| wc -l > swqc-tmp/X10-HA-25G-SFP-count.txt
ifconfig -va | grep -i 25GBASE-SR > swqc-tmp/X10-HA-25G-SFP-list.txt
ifconfig -va | grep -i 25GBASE-SR | wc -l  >> swqc-tmp/$SERIAL-part-count.txt
ifconfig -va | grep -i 25GBASE-SR | wc -l >> swqc-tmp/$SERIAL-diffme.txt
ifconfig -va | grep -i 25GBASE-SR | wc -l >> swqc-tmp/swqc-output.txt
#
#
fi
#
#
#
if echo "$PRODUCT"|grep -Fwqi -e "TRUENAS-X20-HA"  && ifconfig -va | grep -oh "\w*QSFP-SR4-40G\w*"| grep -Fwqi -e QSFP-SR4-40G; then
echo "40G SFP Count" >> swqc-tmp/swqc-output.txt
echo "40G SFP Count" >> swqc-tmp/$SERIAL-diffme.txt
echo "40G SFP Count" >> swqc-tmp/$SERIAL-part-count.txt
#
ifconfig -va | grep -i QSFP-SR4-40G | wc -l > swqc-tmp/X10-HA-40G-SFP-count.txt
ifconfig -va | grep -i QSFP-SR4-40G > swqc-tmp/X10-HA-40G-SFP-list.txt
ifconfig -va | grep -i QSFP-SR4-40G | wc -l  >> swqc-tmp/$SERIAL-part-count.txt
ifconfig -va | grep -i QSFP-SR4-40G | wc -l >> swqc-tmp/$SERIAL-diffme.txt
ifconfig -va | grep -i QSFP-SR4-40G | wc -l >> swqc-tmp/swqc-output.txt
#
#
fi
#
#
#
#
#
#
#
###################################################################
cd /tmp
#
echo "point check L" >> swqc-tmp/swqc-output.txt
echo "point check L" > swqc-tmp/pointcheck-L.txt
#
#
#
#
echo "===============================" >> swqc-tmp/swqc-output.txt
#
#
# Get sensor output information
echo "Sensor Information" >> swqc-tmp/swqc-output.txt
#
ipmitool sdr list >> swqc-tmp/swqc-output.txt
ipmitool sdr list > swqc-tmp/sdr-output.txt
#
#
SDROUT=$( cat swqc-tmp/sdr-output.txt)
#
#
#
echo "===============================" >> swqc-tmp/swqc-output.txt
#
#
# Check Power Supply
# Note: these commands do not work on Mini Systems
# 
#
#

echo "Checking status of Power Supply(s)" >> swqc-tmp/$SERIAL-part-count.txt
echo "Checking status of Power Supply(s)" >> swqc-tmp/swqc-output.txt
echo "status other than 0x01 needs to be rejected" >> swqc-tmp/swqc-output.txt
#echo "status other than 0x01 needs to be rejected" >> swqc-tmp/$SERIAL-part-count.txt
# 
ipmitool sdr list| grep -i '^PS' >> swqc-tmp/swqc-output.txt
ipmitool sdr list| grep -i '^PS' > swqc-tmp/sdr-ps-output.txt
ipmitool sdr list| grep -i '^PS' >> swqc-tmp/$SERIAL-part-count.txt
# status other than 0x01 needs to be rejected
#
#
PSSDROUT=$(cat swqc-tmp/sdr-ps-output.txt)
#
#  
ipmitool sdr type 'Power Supply' >> swqc-tmp/swqc-output.txt
ipmitool sdr type 'Power Supply' > swqc-tmp/sdr-type-power-supply-out.txt
#
SDRTYPEPOWER=$(cat swqc-tmp/sdr-type-power-supply-out.txt)
#
#
ipmitool sel list | grep -i "power" >> swqc-tmp/swqc-output.txt
ipmitool sel list | grep -i "power" > swqc-tmp/sel-power-out.txt
#
#
POWERSEL=$(cat swqc-tmp/sel-power-out.txt)
#
#
echo "===============================" >> swqc-tmp/swqc-output.txt
#
#
echo "Power Supply State" >> swqc-tmp/$SERIAL-diffme.txt
dmidecode -t chassis | grep -i "Power Supply State:" >> swqc-tmp/$SERIAL-diffme.txt
echo "Power Supply State" >> swqc-tmp/$SERIAL-part-count.txt
dmidecode -t chassis | grep -i "Power Supply State:" >> swqc-tmp/$SERIAL-part-count.txt
#
#
#
#
ECHO "Power Supply Status"  >> swqc-tmp/$SERIAL-diffme.txt 
ipmitool sdr list | grep -i 'PS[1|2]' >> swqc-tmp/$SERIAL-diffme.txt
#
#
#
#
#
echo "Boot Pool State" >> swqc-tmp/$SERIAL-diffme.txt
echo "Boot Pool State" >> swqc-tmp/swqc-output.txt
echo "Boot Pool State" >> swqc-tmp/$SERIAL-part-count.txt
zpool status boot-pool| grep -i state: >> swqc-tmp/$SERIAL-diffme.txt
zpool status boot-pool| grep -i state: >> swqc-tmp/swqc-output.txt
zpool status boot-pool| grep -i state: >> swqc-tmp/$SERIAL-part-count.txt
#
echo "===============================" >> swqc-tmp/swqc-output.txt
#
# check NVME flash
#
#
# nvmecontrol devlist | grep -i nvme1:>> swqc-tmp/swqc-output.txt
#
# nvmecontrol devlist | grep -i nvme1:> swqc-tmp/nvme-output.txt
#
#NVME=$( cat swqc-tmp/nvme-output.txt)
#
echo "===============================" >> swqc-tmp/swqc-output.txt
#
touch swqc-tmp/smart-sched-out.txt
#
echo "Smart Test Verification" >> swqc-tmp/$SERIAL-diffme.txt
#
echo 'select * from tasks_smarttest' | sqlite3 /data/freenas-v1.db > swqc-tmp/smart-sched-out.txt
#
SMARTOUT=$(cat swqc-tmp/smart-sched-out.txt)
#
#
touch swqc-tmp/smart-sched-results.txt
#
if cat swqc-tmp/smart-sched-out.txt | cut -d "|" -f3|grep -Fwqi -e "SHORT" && cat swqc-tmp/smart-sched-out.txt | cut -d "," -f1-12 | grep -oh "\w*feb,mar,apr,may,jun,jul,aug,sep,oct,nov,dec|sat|0\w*"| grep -Fwqi -e "feb,mar,apr,may,jun,jul,aug,sep,oct,nov,dec|sat|0"; then
#
echo "Smart Test Correctly Set" > swqc-tmp/smart-sched-results.txt
echo "Smart Test Correctly Set" >> swqc-tmp/$SERIAL-diffme.txt
#
else
#
#
echo "Smart Test Not Set" > swqc-tmp/smart-sched-results.txt
echo "Smart Test Not Set" >> swqc-tmp/$SERIAL-diffme.txt
#
fi
#
#
touch swqc-tmp/sshroot-out.txt
#
echo "Verify Login as root SSH Setup" >> swqc-tmp/$SERIAL-diffme.txt
#
echo 'select ssh_rootlogin from services_ssh' | sqlite3 /data/freenas-v1.db  > swqc-tmp/sshroot-out.txt
#
SSHROOT=$(cat swqc-tmp/sshroot-out.txt)
#
#
touch swqc-tmp/sshroot-out-results.txt
#
if cat swqc-tmp/sshroot-out.txt | cut -d "|" -f3|grep -Fwqi -e "1"; then
#
echo "Root SSH Correctly Set" > swqc-tmp/sshroot-out-results.txt
echo "Root SSH Correctly Set" >> swqc-tmp/$SERIAL-diffme.txt
#
else
#
#
echo "Root SSH Not Set" > swqc-tmp/sshroot-out-results.txt
echo "Root SSH Not Set" >> swqc-tmp/$SERIAL-diffme.txt
#
fi
#
#
echo "===============================" >> swqc-tmp/swqc-output.txt

touch swqc-tmp/$SERIAL-config-sheet-ver.txt

echo "Config Sheet Verification" >> swqc-tmp/$SERIAL-config-sheet-ver.txt


echo "hostname" >> swqc-tmp/$SERIAL-config-sheet-ver.txt

echo "$SYSHOSTNAME" >> swqc-tmp/$SERIAL-config-sheet-ver.txt

echo "DNS Name Servers" >> swqc-tmp/$SERIAL-config-sheet-ver.txt

echo "$DNSSERVERS" >> swqc-tmp/$SERIAL-config-sheet-ver.txt

echo " IP Settings" >> swqc-tmp/$SERIAL-config-sheet-ver.txt
echo "$IPSETTINGS" >> swqc-tmp/$SERIAL-config-sheet-ver.txt

echo "zpools" >> swqc-tmp/$SERIAL-config-sheet-ver.txt

echo "$ZPLIST" >> swqc-tmp/$SERIAL-config-sheet-ver.txt

echo "$ZPSTATUS" >> swqc-tmp/$SERIAL-config-sheet-ver.txt

echo "End of Config Sheet Verification" >> swqc-tmp/$SERIAL-config-sheet-ver.txt


#
#
#
# Logging Information
#
echo "Logging Information" >> swqc-tmp/swqc-output.txt
echo "logging Information" >> swqc-tmp/$SERIAL-part-count.txt
#
#
touch swqc-tmp/mca-errors.txt
#
< /var/log/messages grep -iC6 "MCA" | grep -i "Error" >> swqc-tmp/mca-errors.txt
#
#
MCARRORS=$(cat swqc-tmp/mca-errors.txt)
#
#
touch swqc-tmp/mcelog.txt 
#
mcelog >> swqc-tmp/mcelog.txt 
#
#

#
ipmitool sel list  >> swqc-tmp/swqc-output.txt
ipmitool sel list > swqc-tmp/selinfo-output.txt
ipmitool sel list >> swqc-tmp/$SERIAL-part-count.txt
echo "Sel List"  >> swqc-tmp/$SERIAL-diffme.txt
ipmitool sel list  >> swqc-tmp/$SERIAL-diffme.txt
#
#
SELINFO=$( cat swqc-tmp/selinfo-output.txt)
#
#
touch swqc-tmp/alert-list.txt
midclt call alert.list > swqc-tmp/alert-list.txt
#
#
# clearning chassis intrusion
#
ipmitool raw 0x30 0x03
#
#
# clearing sel info 
ipmitool sel clear
#
#
echo "===============================" >> swqc-tmp/swqc-output.txt
#
echo "point check M" >> swqc-tmp/swqc-output.txt
echo "point check M" > swqc-tmp/pointcheck-M.txt
#
cd /tmp
#
# Collect a debug and move it into swq-tmp
# 
#
freenas-debug -A
#
# echo " Smart Info " >> swqc-tmp/swqc-output.txt
# cat smart.out | grep -i result >> swqc-tmp/swqc-output.txt
# cat smart.out >> swqc-tmp/swqc-output.txt
mv fndebug swqc-tmp
mv smart.out swqc-tmp
#
echo " End of Report" >> swqc-tmp/$SERIAL-part-count.txt
#
# compress output file swqc-tmp scp it to megabeast
#
tar cfz "$SERIAL.tar.gz" swqc-tmp/ 
#
#
#
#
#
echo "===============================" >> swqc-tmp/swqc-output.txt
#
#
#
echo "setting up for mounting sj storage"
#
#
echo "Mounting SJ-Storage"
echo "[REPLACE_WITH_SERVER_ADDRESS:ROOT]" > ~/.nsmbrc
echo "password=REPLACE_WITH_PASSWORD" >> ~/.nsmbrc
cat ~/.nsmbrc
mkdir /mnt/sj-storage
mount_smbfs -N -I REPLACE_WITH_SERVER_IP //root@REPLACE_WITH_SERVER_IP/sj-storage/ /mnt/sj-storage/ || mount -t cifs -o vers=3,username=root,password=REPLACE_WITH_PASSWORD '//REPLACE_WITH_SERVER_IP/sj-storage/' /mnt/sj-storage/
cat /mnt/sj-storage/swqc-output/smbconnection-verified.txt >> swqc-tmp/swqc-output.txt
cat /mnt/sj-storage/swqc-output/smbconnection-verified.txt > swqc-tmp/smb-verified.txt
echo "SJ-Storage Mounted"
#
#
#
echo "===============================" >> swqc-tmp/swqc-output.txt
#              
#
echo "Copying tar.gz file to swqc-output on sj-storage"
#
cd /tmp
#
#
cp *.tar.gz /mnt/sj-storage/swqc-output/
#
#
#
echo "Finished copying tar.gz file to swqc-output on sj-storage"
#
#
#
echo "===============================" >> swqc-tmp/swqc-output.txt
#
#
#
#
echo "Cleanup" 
#
#
#rm -rf swqc-tmp
#
#
#
#
#
#
rm -rf swqc-tmp
rm -rf $SERIAL.tar.gz
unset HISTFILE
rm /root/.zsh-histfile
#
exit

