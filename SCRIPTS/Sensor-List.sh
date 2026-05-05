#!/bin/bash
# Title: Sensor-List.sh
# Description: Grabs SDR & Sensor Info
# Author: jgarcia@ixsystems.com
# Updated: 02:08:2023
# Version: 0.1
#########################################################################################################
# DEPENDENCIES:
#
# dialog needs to be installed: sudo apt-get install dialog -y
# ipmitool needs to be installed: sudo apt-get install ipmitool -y
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
# 8. When inputing serials on File.txt leave a blank line at end of document otherwise last line won't be read.
#########################################################################################################


# Removing previous temp folder

rm -rf OUTPUT/sensor-tmp/

# This is the directory where the data we collect will go

mkdir OUTPUT/sensor-tmp

# Collecting order number

dialog --inputbox "Enter Order Number" 10 60 2>OUTPUT/sensor-tmp/Order-Number.txt
ORDER=$(cat OUTPUT/sensor-tmp/Order-Number.txt)

# Removing previous files

rm -rf OUTPUT/"$ORDER"-SENSOR-CHECK.tar.gz OUTPUT/"$ORDER"-SENSOR-CHECK

echo "==========================================================================" >>OUTPUT/sensor-tmp/LINE-Output.txt

mkdir OUTPUT/sensor-tmp/DIFF
touch OUTPUT/sensor-tmp/Field1-Output.txt
touch OUTPUT/sensor-tmp/Field2-Output.txt
touch OUTPUT/sensor-tmp/Field3-Output.txt
touch OUTPUT/sensor-tmp/Field4-Output.txt

cp ~/3-iX-WSL-CC/SCRIPTS/KEY.txt OUTPUT/ix-tmp/Input.txt

FILE=OUTPUT/ix-tmp/Input.txt
SERIAL=""
IP=""
USER=""
PASSWORD=""
exec 3<&0
exec 0<$FILE
while read -r LINE; do
  SERIAL=$(echo "$LINE" | cut -d " " -f 1)
  IP=$(echo "$LINE" | cut -d " " -f 2)
  USER=$(echo "$LINE" | cut -d " " -f 3)
  PASSWORD=$(echo "$LINE" | cut -d " " -f 4)

  echo "$IP" >OUTPUT/sensor-tmp/Field1-Output.txt
  echo "$USER" >OUTPUT/sensor-tmp/Field2-Output.txt
  echo "$PASSWORD" >OUTPUT/sensor-tmp/Field3-Output.txt
  echo "$SERIAL" >OUTPUT/sensor-tmp/Field4-Output.txt

  echo "==========================================================================" >>OUTPUT/sensor-tmp/LINE-Output.txt

  ipmitool -H "$IP" -U "$USER" -P "$PASSWORD" power cycle

  echo "==========================================================================" >>OUTPUT/sensor-tmp/LINE-Output.txt

done

yes | pv -SpeL1 -s 200 >/dev/null

FILE=OUTPUT/ix-tmp/Input.txt
SERIAL=""
IP=""
USER=""
PASSWORD=""
exec 3<&0
exec 0<$FILE
while read -r LINE; do
  SERIAL=$(echo "$LINE" | cut -d " " -f 1)
  IP=$(echo "$LINE" | cut -d " " -f 2)
  USER=$(echo "$LINE" | cut -d " " -f 3)
  PASSWORD=$(echo "$LINE" | cut -d " " -f 4)

  echo "$IP" >OUTPUT/sensor-tmp/Field1-Output.txt
  echo "$USER" >OUTPUT/sensor-tmp/Field2-Output.txt
  echo "$PASSWORD" >OUTPUT/sensor-tmp/Field3-Output.txt
  echo "$SERIAL" >OUTPUT/sensor-tmp/Field4-Output.txt

  ipmitool -H "$IP" -U "$USER" -P "$PASSWORD" sdr list >OUTPUT/sensor-tmp/"$ORDER"-SDR-"$SERIAL"-"$IP".txt

  ipmitool -H "$IP" -U "$USER" -P "$PASSWORD" sensor list >OUTPUT/sensor-tmp/"$ORDER"-SENSOR-"$SERIAL"-"$IP".txt

done

# Creating GOLD file for diff

SERIAL=$(head <SCRIPTS/FILE.txt -n 1 | cut -d " " -f 1)
IP=$(head <SCRIPTS/FILE.txt -n 1 | cut -d " " -f 2)

cp OUTPUT/sensor-tmp/"$ORDER"-SDR-"$SERIAL"-"$IP".txt OUTPUT/sensor-tmp/DIFF/GOLD-SDR-Data.txt
cp OUTPUT/sensor-tmp/"$ORDER"-SENSOR-"$SERIAL"-"$IP".txt OUTPUT/sensor-tmp/DIFF/GOLD-SENSOR-Data.txt

# Diffing each system for errors

FILE=OUTPUT/ix-tmp/Input.txt
SERIAL=""
IP=""
USER=""
PASSWORD=""
exec 3<&0
exec 0<$FILE
while read -r LINE; do
  SERIAL=$(echo "$LINE" | cut -d " " -f 1)
  IP=$(echo "$LINE" | cut -d " " -f 2)
  USER=$(echo "$LINE" | cut -d " " -f 3)
  PASSWORD=$(echo "$LINE" | cut -d " " -f 4)

  echo "------------------------------------------------------$SERIAL------------------------------------------------------" >>OUTPUT/sensor-tmp/DIFF/"$ORDER"-SDR-DIFF.txt
  diff -y -W 200 --suppress-common-lines OUTPUT/sensor-tmp/DIFF/GOLD-SDR-Data.txt OUTPUT/sensor-tmp/"$ORDER"-SDR-"$SERIAL"-"$IP".txt >>OUTPUT/sensor-tmp/DIFF/"$ORDER"-SDR-DIFF.txt

  echo "------------------------------------------------------$SERIAL------------------------------------------------------" >>OUTPUT/sensor-tmp/DIFF/"$ORDER"-SENSOR-DIFF.txt
  diff -y -W 200 --suppress-common-lines OUTPUT/sensor-tmp/DIFF/GOLD-SENSOR-Data.txt OUTPUT/sensor-tmp/"$ORDER"-SENSOR-"$SERIAL"-"$IP".txt >>OUTPUT/sensor-tmp/DIFF/"$ORDER"-SENSOR-DIFF.txt

  # Cleanup

  ipmitool -H "$IP" -U "$USER" -P "$PASSWORD" chassis power cycle

  ipmitool -H "$IP" -U "$USER" -P "$PASSWORD" chassis bootparam set bootflag force_bios

done

mv OUTPUT/sensor-tmp OUTPUT/"$ORDER"-SENSOR-CHECK

# Compress output file

tar cfz OUTPUT/"$ORDER-SENSOR-CHECK.tar.gz" OUTPUT/"$ORDER"-SENSOR-CHECK

exit
