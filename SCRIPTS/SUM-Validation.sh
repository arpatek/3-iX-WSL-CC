#!/bin/bash
# Title: SUM-Validation.sh
# Description: Grabs Current BIOS Configuration & Various Systems Info
# Author: Juan Garcia
# Updated: 04:27:2022
# Version: 0.1
#########################################################################################################
# DEPENDENCIES:
#
# dialog needs to be installed: sudo apt-get install dialog -y
# ipmitool needs to be installed: sudo apt-get install ipmitool -y
# Supermicro SUM tool (Linux version) needs to be installed with script running in the SUM tool directory
#########################################################################################################
# TROUBLESHOOTING IF SCRIPT DOES NOT WORK:
#
# 1. Check IP ensure it's correct.
# 2. Ensure IP is pingable.
# 3. Reboot the sytsem you are on and try again.
# 4. Try from different system.
# 5. If script uses ssh try to manualy ssh into the system the IP may have an old key in the system that the script is running from. You may need to get rid of that ssh key.
# 6. The byte order mark (BOM) may be set. Vi File.txt after entering your information you will see an ^M. Uncheck byte order mark in your txt editor. Re-enter info.
# 7. In your txt editor go to tools and change End of line to Unix.
# 8. When inputing serials on ip.txt leave a blank line at end of document otherwise last line won't be read.
#########################################################################################################

# Removing previous temp folder

rm -rf OUTPUT/val-tmp/

# This is the directory where the data we collect will go

mkdir OUTPUT/val-tmp

# Collecting name of person performing CC

dialog --inputbox "Enter The Name Of The Person Performing CC Here" 10 60 2>OUTPUT/val-tmp/CC-Person.txt

# Collecting order number

dialog --inputbox "Enter Order Number" 10 60 2>OUTPUT/val-tmp/Order-Temp.txt
ORDER=$(cat OUTPUT/val-tmp/Order-Temp.txt)

# Removing previous files

rm -rf OUTPUT/"$ORDER"-SUM-VAL.tar.gz OUTPUT/"$ORDER"-SUM-VAL

echo "==========================================================================" >>OUTPUT/val-tmp/LINE-Output.txt

clear

mkdir OUTPUT/val-tmp/BIOS-Files
mkdir OUTPUT/val-tmp/Event-Logs

cp ~/3-iX-WSL-CC/SCRIPTS/KEY.txt OUTPUT/val-tmp/Input.txt

FILE=OUTPUT/val-tmp/Input.txt
exec 3<&0
exec 0<$FILE
while read -r LINE; do
  SERIAL=$(echo "$LINE" | cut -d " " -f 1)
  IP=$(echo "$LINE" | cut -d " " -f 2)
  USER=$(echo "$LINE" | cut -d " " -f 3)
  PASSWORD=$(echo "$LINE" | cut -d " " -f 4)

  echo "IP is $IP"
  echo "USER is $USER"
  echo "PASSWORD is $PASSWORD"
  echo "SERIAL is $SERIAL"

  # Grabbing system BIOS configuration & event logs

  echo "==========================================================================" >>OUTPUT/val-tmp/LINE-Output.txt

  echo -e "\nRetreiving BIOS Configuration\n"
  echo -e "------------------------------\n\n"

  ./SCRIPTS/sum -i "$IP" -u "$USER" -p "$PASSWORD" -c GetCurrentBiosCfg --file "bioscfg-$ORDER-$SERIAL-$IP".xml
  mv -i bioscfg-"$ORDER"-"$SERIAL"-"$IP".xml OUTPUT/val-tmp/BIOS-Files

  echo -e "\nRetreiving Event Logs\n"
  echo -e "----------------------\n\n"

  ./SCRIPTS/sum -i "$IP" -u "$USER" -p "$PASSWORD" -c GetEventLog --file "eventlog-$ORDER-$SERIAL-$IP"
  mv -i eventlog-"$ORDER"-"$SERIAL"-"$IP" OUTPUT/val-tmp/Event-Logs

  echo -e "\nFinished Collecting Event Log And BIOS Configs\n"
  echo -e "-----------------------------------------------\n"

  echo "==========================================================================" >>OUTPUT/val-tmp/LINE-Output.txt

  echo -e "\n--------"
  echo "$SERIAL"
  echo -e "--------\n\n"

  # Gathering system information & boot to BIOS

  ipmitool -I lanplus -H "$IP" -U "$USER" -P "$PASSWORD" power cycle

  yes | pv -SpeL1 -s 45 >/dev/null # timed delay: -S stops after -s bytes at -L 1 byte/sec ≈ 45 second wait with progress display

  ./SCRIPTS/sum -i "$IP" -u "$USER" -p "$PASSWORD" -C GetDmiInfo >OUTPUT/val-tmp/"$ORDER"-DMI-Info-Data-"$SERIAL"-"$IP".txt
  echo -e "\nCollected DMI Info\n"
  echo -e "--------------------"
  ipmitool -I lanplus -H "$IP" -U "$USER" -P "$PASSWORD" raw 0x30 0x03
  echo -e "Reset Chassis Intrusion\n"
  echo -e "------------------------\n"
  ipmitool -I lanplus -H "$IP" -U "$USER" -P "$PASSWORD" sdr list >OUTPUT/val-tmp/"$ORDER"-Sensor-Via-IPMI-Data-"$SERIAL"-"$IP".txt
  echo -e "Collected SDR List Info\n"
  echo -e "------------------------\n"
  ./SCRIPTS/sum -i "$IP" -u "$USER" -p "$PASSWORD" -C CheckSensorData >OUTPUT/val-tmp/"$ORDER"-Sensor-Data-"$SERIAL"-"$IP".txt
  echo -e "Collected Sensor Data\n"
  echo -e "----------------------\n"
  ./SCRIPTS/sum -i "$IP" -u "$USER" -p "$PASSWORD" -C CheckAssetInfo >OUTPUT/val-tmp/"$ORDER"-CheckAssetInfo-Data-"$SERIAL"-"$IP".txt
  echo -e "Checked Asset Info\n"
  echo -e "-------------------\n"
  ipmitool -I lanplus -H "$IP" -U "$USER" -P "$PASSWORD" bmc info >OUTPUT/val-tmp/"$ORDER"-BMC-Via-ipmitool-Data-"$SERIAL"-"$IP".txt
  echo -e "Gathered BMC Info\n"
  echo -e "------------------\n"
  ./SCRIPTS/sum -i "$IP" -u "$USER" -p "$PASSWORD" -C CheckAssetInfo | grep -Ei 'MAC Address' >OUTPUT/val-tmp/"$ORDER"-MAC-Address-Data-"$SERIAL"-"$IP".txt
  echo -e "Retrieved MAC Address\n"
  echo -e "----------------------\n"
  ./SCRIPTS/sum -i "$IP" -u "$USER" -p "$PASSWORD" -C QueryProductKey >OUTPUT/val-tmp/"$ORDER"-Query-Product-Key-Data-"$SERIAL"-"$IP".txt
  echo -e "Getting Product Key\n"
  echo -e "--------------------\n"
  ipmitool -I lanplus -H "$IP" -U "$USER" -P "$PASSWORD" sdr type 'Power Supply' >OUTPUT/val-tmp/"$ORDER"-SDR-Type-Power-Supply-Data-"$SERIAL"-"$IP".txt
  echo -e "Looked At Power Supply\n"
  echo -e "-----------------------\n"
  ./SCRIPTS/sum -i "$IP" -u "$USER" -p "$PASSWORD" -C CheckOOBSupport >OUTPUT/val-tmp/"$ORDER"-OOB-Support-Check-Data-"$SERIAL"-"$IP".txt
  echo -e "Checked OOB Support\n"
  echo -e "--------------------\n"
  ipmitool -I lanplus -H "$IP" -U "$USER" -P "$PASSWORD" sel list >OUTPUT/val-tmp/"$ORDER"-SEL-List-Data-"$SERIAL"-"$IP".txt
  echo -e "Retreived SEL List\n"
  echo -e "-------------------\n"
  ipmitool -I lanplus -H "$IP" -U "$USER" -P "$PASSWORD" sensor list | grep -i 'FAN' >OUTPUT/val-tmp/"$ORDER"-FAN-REMOVAL-Fan-Check-Via-IPMI-Data-"$SERIAL"-"$IP".txt
  echo -e "Checked 'FAN[1458]'\n"
  echo -e "--------------------\n"

  # OOB/DCMS license check

  {
    echo -e "==========================================================================\n\n"
    echo -e "Verifying OOB/DCMS Keys For $SERIAL \n\n"
    ./SCRIPTS/sum -i "$IP" -u "$USER" -p "$PASSWORD" -C QueryProductKey
    echo -e "\n\n--------------------------------------------------------------------------\n\n"
    ./SCRIPTS/sum -i "$IP" -u "$USER" -p "$PASSWORD" -C CheckOOBSupport
    echo -e "\n\n==========================================================================\n\n"
  } >>OUTPUT/val-tmp/"$ORDER"-OOB-DCMS-LICENSE.txt

  echo -e "\nClearing SEL List\n"
  echo -e "------------------\n\n"
  ipmitool -I lanplus -H "$IP" -U "$USER" -P "$PASSWORD" sel clear
  echo -e "\nPower Cycle System\n"
  echo -e "-------------------\n\n"
  ipmitool -I lanplus -H "$IP" -U "$USER" -P "$PASSWORD" chassis power cycle
  echo -e "\nBoot To BIOS\n"
  echo -e "-------------\n\n"
  ipmitool -I lanplus -H "$IP" -U "$USER" -P "$PASSWORD" chassis bootparam set bootflag force_bios
  echo -e "\n\n"

done

# Creating GOLD file for BIOS diff

echo -e "\nCreating GOLD File For BIOS Diff\n"
echo -e "---------------------------------\n\n"

LINE=$(cat <OUTPUT/val-tmp/Input.txt | head -n 1 | cut -d " " -f 1)
IP=$(cat <OUTPUT/val-tmp/Input.txt | head -n 1 | cut -d " " -f 2)

cp OUTPUT/val-tmp/BIOS-Files/bioscfg-"$ORDER"-"$LINE"-"$IP" OUTPUT/val-tmp/BIOS-Files/bioscfg-"$ORDER"-GOLD

# Diffing each system for errors

echo -e "\nDiffing Each System For Errors\n"
echo -e "-------------------------------\n\n"

FILE=OUTPUT/val-tmp/Input.txt
SERIAL=""
IP=""
exec 3<&0
exec 0<$FILE
while read -r LINE; do
  SERIAL=$(cut <"$LINE" -d " " -f 1)
  IP=$(cut <"$LINE" -d " " -f 2)

  echo -e "\nDiffing $SERIAL\n"
  echo -e "-----------------\n\n"
  echo "------------------------------------------------------$SERIAL------------------------------------------------------" >>OUTPUT/val-tmp/BIOS-Files/"$ORDER"-BIOS-DIFF.txt
  diff -y -W 200 --suppress-common-lines OUTPUT/val-tmp/BIOS-Files/bioscfg-"$ORDER"-GOLD OUTPUT/val-tmp/BIOS-Files/bioscfg-"$ORDER"-"$SERIAL"-"$IP" >>OUTPUT/val-tmp/BIOS-Files/"$ORDER"-BIOS-DIFF.txt

done

mv OUTPUT/val-tmp OUTPUT/"$ORDER"-SUM-VAL

# Compress output file

tar cfz OUTPUT/"$ORDER-SUM-VAL.tar.gz" OUTPUT/"$ORDER"-SUM-VAL

exit
