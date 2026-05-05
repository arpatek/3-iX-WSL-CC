#!/bin/bash
# Title: BIOS-Default.sh
# Description: Set BIOS to Default settings
# Author: Juan Garcia
# Updated: 04:20:2022
# Version: 0.1
#########################################################################################################
# DEPENDENCIES:
#
# dialog needs to be installed: sudo apt-get install dialog -y
# psql needs to be installed: sudo apt-get install postgresql-client-common -y
# lynx needs to be installed: sudo apt-get install lynx -y
# curl needs to be installed: sudo apt-get install curl -y
# Supermicro SUM tool (Linux version) needs to be installed with script running in the SUM tool directory
#
#########################################################################################################
# TROUBLESHOOTING IF SCRIPT DOES NOT WORK:
#
# 1. Check IP ensure it's correct.
# 2. Ensure IP is pingable.
# 3. Reboot the sytsem you are on and try again.
# 4. Try from different system.
# 5. If script uses ssh try to manualy ssh into the system the IP may have an old key in the system that the script is running from. You may need to get rid of that ssh key.
# 6. The byte order mark (BOM) may be set. Vi IP.txt after entering your information you will see an ^M. Uncheck byte order mark in your txt editor. Re-enter info.
# 7. In your txt editor go to tools and change End of line to Unix.
# 8. When inputing serials on IP.txt leave a blank line at end of document otherwise last line won't be read.
#########################################################################################################

# Removing previous temp folder

rm -rf OUTPUT/bios-tmp

# This is the directory where the data we collect will go

mkdir OUTPUT/bios-tmp

# Collecting name of person performing CC

dialog --inputbox "Enter The Name Of The Person Performing CC Here" 10 60 2>OUTPUT/bios-tmp/CC-Person.txt

# Collecting order number for HRT systems

dialog --inputbox "Enter Order Number" 10 60 2>OUTPUT/bios-tmp/Order-Num.txt

ORDER=$(cat OUTPUT/bios-tmp/Order-Num.txt)

# Removing previous files

rm -rf OUTPUT/"$ORDER"-BIOS-DEFAULT.tar.gz OUTPUT/"$ORDER"-BIOS-DEFAULT

{
  echo "=========================================================================="
  echo "ORDER INFORMATION"
  echo "Order Number: $ORDER"
  echo "=========================================================================="
} >>OUTPUT/bios-tmp/LINE-Output.txt

clear

cp ~/3-iX-WSL-CC/SCRIPTS/KEY.txt OUTPUT/bios-tmp/Input.txt

FILE=OUTPUT/bios-tmp/Input.txt
SERIAL=""
exec 3<&0
exec 0<$FILE
while read -r LINE; do
  SERIAL=$(echo "$LINE" | cut -d " " -f 1)

  echo "$IP" >>OUTPUT/bios-tmp/LINE-Output.txt
  echo "$SERIAL" >OUTPUT/bios-tmp/LINE-Output.txt

  echo "==========================================================================" >>OUTPUT/bios-tmp/LINE-Output.txt

  # Grabbing Burn-In information from PBS logs

  lynx --dump https://<PBS_ARCHIVE_HOST>/pbsv4/logs/"$SERIAL"/ | tail -1 | cut -d "/" -f7 >OUTPUT/bios-tmp/"$SERIAL"-DIR.txt
  PBSDIRECTORY=$(cat OUTPUT/bios-tmp/"$SERIAL"-DIR.txt)
  curl https://<PBS_ARCHIVE_HOST>/pbsv4/logs/"$SERIAL"/"$PBSDIRECTORY"/ipmi_summary.txt -o OUTPUT/bios-tmp/"$SERIAL"-PBS-IPMI_Summary.txt

  if PBSDIRECTORY=$(cat OUTPUT/bios-tmp/"$SERIAL"-DIR.txt); then
    echo "$PBSDIRECTORY" >OUTPUT/bios-tmp/"$SERIAL"-DIR-Check.txt
    curl https://<PBS_ARCHIVE_HOST>/pbsv4/logs/"$SERIAL"/"$PBSDIRECTORY"/ipmi_summary.txt -o OUTPUT/bios-tmp/"$SERIAL"-PBS-IPMI_Summary.txt

  fi

  curl https://<PBS_ARCHIVE_HOST>/pbsv4/logs/"$SERIAL"/"$PBSDIRECTORY"/Passmark_Log.cert.htm -o OUTPUT/bios-tmp/"$SERIAL"-PBS-Passmark_Log.cert.htm

  # Collecting IPMI IP address

  sed -e "s/\r//g" OUTPUT/bios-tmp/"$SERIAL"-PBS-IPMI_Summary.txt >OUTPUT/bios-tmp/"$SERIAL"-IPMI-Summary.txt

  grep <OUTPUT/bios-tmp/"$SERIAL"-IPMI-Summary.txt -E -i "IPv4 Address" | cut -d ":" -f 2 | awk '{$1=$1};1' >OUTPUT/bios-tmp/"$SERIAL"-IPMI-IPAdddress.txt
  IPMIIP=$(cat OUTPUT/bios-tmp/"$SERIAL"-IPMI-IPAdddress.txt)

  # Collecting STD info

  psql -h <DB_HOST> -U <DB_USER> -d <DB_NAME> -c "select c.name, a.model, a.serial, a.rma, a.revision, a.support_number from production_part a, production_system b, production_type c, production_configuration d where a.system_id = b.id and a.type_id = c.id and b.config_name_id = d.id and b.system_serial = '$SERIAL' order by b.system_serial, a.type_id, a.model, a.serial;" >OUTPUT/bios-tmp/"$SERIAL"-STD-Parts.txt
  grep <OUTPUT/bios-tmp/"$SERIAL"-STD-Parts.txt "Unique Password" | cut -d "|" -f 3 | xargs >OUTPUT/bios-tmp/"$SERIAL"-IPMI-Password.txt
  IPMIPASSWORD=$(cat OUTPUT/bios-tmp/"$SERIAL"-IPMI-Password.txt)

  # Reseting BIOS to optimized defaults

  ./SCRIPTS/sum -i "$IPMIIP" -u ADMIN -p "$IPMIPASSWORD" -C LoadDefaultBiosCfg >OUTPUT/bios-tmp/"$SERIAL"-BIOS-Default.txt

  # Check BIOS change completed

  grep <OUTPUT/bios-tmp/"$SERIAL"-BIOS-Default.txt -i "loaded" | tr -s ' ' >OUTPUT/bios-tmp/"$SERIAL"-BIOS-Reset.txt
  BIOSDEFAULT=$(cat OUTPUT/bios-tmp/"$SERIAL"-BIOS-Reset.txt)

  # Verify BIOS changed

  if [[ $BIOSDEFAULT == *"loaded"* ]]; then
    echo "BIOS Reset Successful" >OUTPUT/bios-tmp/BIOS-Verified.txt
    BIOSV=$(cat OUTPUT/bios-tmp/BIOS-Verified.txt)

  fi

  # Dumping data to consolidated output file

  echo "$SERIAL $IPMIIP $BIOSV" | xargs >>OUTPUT/bios-tmp/"$ORDER"-BIOS-Output.txt

done

mv OUTPUT/bios-tmp OUTPUT/"$ORDER"-BIOS-DEFAULT

# Compress output file

tar cfz "OUTPUT/$ORDER-BIOS-DEFAULT.tar.gz" OUTPUT/"$ORDER"-BIOS-DEFAULT

exit
