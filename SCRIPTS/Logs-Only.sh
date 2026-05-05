#!/bin/bash
# Title: CC-Config.sh
# Description: Get PBS Information & Basic System Configuration
# Author: jgarcia@ixsystems.com
# Updated: 05:05:2022
# Version: 5.0
#########################################################################################################
# DEPENDENCIES:
#
# dialog needs to be installed: sudo apt-get install dialog -y
# psql needs to be installed: sudo apt-get install postgresql-client -y
# lynx needs to be installed: sudo apt-get install lynx -y
# curl needs to be installed: sudo apt-get install curl -y
# pv needs to be installed: sudo apt-get install pv -y
# pdfgrep needs to be installed: sudo apt-get install pdgrep -Fy
#########################################################################################################
# TROUBLESHOOTING IF SCRIPT DOES NOT WORK:
#
# 1. Check IP ensure it's correct.
# 2. Ensure IP is pingable.
# 3. Reboot the sytsem you are on and try again.
# 4. Try from different system.
# 5. If script uses ssh try to manualy ssh into the system the IP may have an old key in the system that the script is running from. You may need to get rid of that ssh key.
# 6. The byte order mark (BOM) may be set. Vi Input.txt after entering your information you will see an ^M. Uncheck byte order mark in your txt editor. Re-enter info.
# 7. In your txt editor go to tools and change End of LINE to Unix.
# 8. When inputing serials on Input.txt leave a blank LINE at end of document otherwise last LINE won't be read.
# 9. Sometimes when PBS logs are missing some information we use for our variables, it can cause the script to fail
#########################################################################################################

# Removing previous temp folder

rm -rf OUTPUT/logs-tmp

# This is the directories where the data we collect will go

mkdir OUTPUT/logs-tmp
mkdir OUTPUT/logs-tmp/SWQC
mkdir OUTPUT/logs-tmp/CC

# Collecting name of person performing CC

dialog --inputbox "Enter The Name Of The Person Performing CC Here" 10 60 2>OUTPUT/logs-tmp/CC-Person.txt
CCPERSON=$(tr <OUTPUT/logs-tmp/CC-Person.txt '[:lower:]' '[:upper:]')

# Collecting order number for systems

dialog --inputbox "Enter Order Number" 10 60 2>OUTPUT/logs-tmp/Order-Num.txt
ORDER=$(cat OUTPUT/logs-tmp/Order-Num.txt)

# Removing previous files

rm -rf OUTPUT/"$ORDER"-TEST-LOGS.tar.gz OUTPUT/"$ORDER"-TEST-LOGS
clear

echo "==========================================================================" >>OUTPUT/logs-tmp/Line-Output.txt

# Header for CC report

{
  echo -e "------------------------------------------"
  echo -e "IXSYSTEMS INC. CLIENT CONFIGURATION REPORT"
  echo -e "------------------------------------------"
  date
  echo -e "------------------------------------------"
  echo -e "CC PERSON: $CCPERSON"
  echo -e "------------------------------------------"
  echo -e "ORDER NUMBER: $ORDER"
  echo -e "------------------------------------------\n\n\n\n"
} >>OUTPUT/logs-tmp/"$ORDER"-REPORT.txt

# Grabbring serial number from Input.txt

cp ~/3-iX-WSL-CC/SCRIPTS/KEY.txt OUTPUT/logs-tmp/Input.txt

FILE=OUTPUT/logs-tmp/Input.txt
SERIAL=""
exec 3<&0
exec 0<"$FILE"
while read -r LINE; do
  SERIAL=$(echo "$LINE" | cut -d " " -f1)

  touch OUTPUT/logs-tmp/CC/"$ORDER"-PBS-OUTPUT.txt
  touch OUTPUT/logs-tmp/"$SERIAL"-Username.txt
  touch OUTPUT/logs-tmp/IPMI.txt

  echo "==========================================================================" >>OUTPUT/logs-tmp/Line-Output.txt

  # Grabbing Burn-In information from PBS logs

  lynx --dump https://<PBS_ARCHIVE_HOST>/pbsv4/logs/"$SERIAL"/ | tail -1 | cut -d "/" -f7 >OUTPUT/logs-tmp/"$SERIAL"-DIR.txt
  PBSDIRECTORY=$(cat OUTPUT/logs-tmp/"$SERIAL"-DIR.txt)
  curl https://<PBS_ARCHIVE_HOST>/pbsv4/logs/"$SERIAL"/"$PBSDIRECTORY"/ipmi_summary.txt -o OUTPUT/logs-tmp/"$SERIAL"-PBS-IPMI_Summary.txt

  if PBSDIRECTORY=$(cat OUTPUT/logs-tmp/"$SERIAL"-DIR.txt); then
    echo "$PBSDIRECTORY" >OUTPUT/logs-tmp/"$SERIAL"-DIR-Check.txt
    curl https://<PBS_ARCHIVE_HOST>/pbsv4/logs/"$SERIAL"/"$PBSDIRECTORY"/ipmi_summary.txt -o OUTPUT/logs-tmp/"$SERIAL"-PBS-IPMI_Summary.txt

  fi

  # Grabbing Passmark Log

  curl https://<PBS_ARCHIVE_HOST>/pbsv4/logs/"$SERIAL"/"$PBSDIRECTORY"/Passmark_Log.cert.htm -o OUTPUT/logs-tmp/"$SERIAL"-PBS-Passmark_Log.cert.htm
  lynx --dump OUTPUT/logs-tmp/"$SERIAL"-PBS-Passmark_Log.cert.htm >OUTPUT/logs-tmp/"$SERIAL"-Lynx-Cert.txt
  cat OUTPUT/logs-tmp/"$SERIAL"-Lynx-Cert.txt
  lynx --dump OUTPUT/logs-tmp/"$SERIAL"-PBS-Passmark_Log.cert.htm | grep -F "TEST RUN" >OUTPUT/logs-tmp/"$SERIAL"-Test-Run.txt
  tr -s ' ' <OUTPUT/logs-tmp/"$SERIAL"-Test-Run.txt | cut -d ' ' -f 4 | awk '{$1=$1};1' >OUTPUT/logs-tmp/"$SERIAL"-PF.txt
  PASSFAIL=$(cat OUTPUT/logs-tmp/"$SERIAL"-PF.txt)

  if [[ "$PASSFAIL" == "PASSED" ]]; then
    echo "[PASSED]" >OUTPUT/logs-tmp/"$SERIAL"-Passed.txt
  elif [[ "$PASSFAIL" == "FAILED" ]]; then
    echo "[FAILED]" >OUTPUT/logs-tmp/"$SERIAL"-Passed.txt
  fi

  PASSVER=$(cat OUTPUT/logs-tmp/"$SERIAL"-Passed.txt)

  curl https://<PBS_ARCHIVE_HOST>/pbsv4/logs/"$SERIAL"/"$PBSDIRECTORY"/Passmark_Log.htm -o OUTPUT/logs-tmp/"$SERIAL"-PBS-Passmark_Log.htm
  echo -e "https://<PBS_ARCHIVE_HOST>/pbsv4/logs/$SERIAL/$PBSDIRECTORY/Passmark_Log.cert.htm" >OUTPUT/logs-tmp/"$SERIAL"-CERT.txt
  CERT=$(cat OUTPUT/logs-tmp/"$SERIAL"-CERT.txt)

  # CPU presence check

  lynx --dump OUTPUT/logs-tmp/"$SERIAL"-PBS-Passmark_Log.cert.htm | grep -E -i 'CPU 0|CPU 1' >OUTPUT/logs-tmp/"$SERIAL"-CPU-Presence.txt
  if ! [ -s OUTPUT/logs-tmp/"$SERIAL"-CPU-Presence.txt ]; then
    echo "[NO CPU TEMP DETECTED]" >OUTPUT/logs-tmp/"$SERIAL"-NO-CPU-Presence.txt
  fi

  NOCPUTEMP=$(cat OUTPUT/logs-tmp/"$SERIAL"-NO-CPU-Presence.txt)

  # CPU temp check

  lynx --dump OUTPUT/logs-tmp/"$SERIAL"-PBS-Passmark_Log.cert.htm | grep -E -i 'CPU 0|CPU 1' | xargs >OUTPUT/logs-tmp/"$SERIAL"-CPU-Temp.txt
  cut <OUTPUT/logs-tmp/"$SERIAL"-CPU-Temp.txt -d " " -f5 | cut -c 1-2 >OUTPUT/logs-tmp/"$SERIAL"-CPU-Max.txt
  read -r num <OUTPUT/logs-tmp/"$SERIAL"-CPU-Max.txt
  if [[ "$num" -gt 89 ]]; then
    echo "[CPU TEMP ABOVE THRESHOLD]" >OUTPUT/logs-tmp/"$SERIAL"-CPU-Error.txt
  else
    echo "[CPU TEMP OK]"
  fi

  CPUTEMP=$(cat OUTPUT/logs-tmp/"$SERIAL"-CPU-Error.txt)

  # Checking to ensure system ran with test disk

  lynx --dump OUTPUT/logs-tmp/"$SERIAL"-PBS-Passmark_Log.cert.htm | grep ") PASS" | sed -n 2p | awk '{$1=$1};1' >OUTPUT/logs-tmp/"$SERIAL"-Disk00.txt
  DISK00PF=$(cat OUTPUT/logs-tmp/"$SERIAL"-Disk00.txt)

  # Collecting test duration

  lynx --dump OUTPUT/logs-tmp/"$SERIAL"-PBS-Passmark_Log.cert.htm | grep -F "Test Duration" | awk '{$1=$1};1' >OUTPUT/logs-tmp/"$SERIAL"-Test-Duration.txt
  TESTDURATION=$(cat OUTPUT/logs-tmp/"$SERIAL"-Test-Duration.txt)

  # Collecting IPMI IP address

  sed -e "s/\r//g" OUTPUT/logs-tmp/"$SERIAL"-PBS-IPMI_Summary.txt >OUTPUT/logs-tmp/"$SERIAL"-IPMI-Summary.txt

  grep <OUTPUT/logs-tmp/"$SERIAL"-IPMI-Summary.txt -E -i "IPv4 Address" | cut -d ":" -f 2 | awk '{$1=$1};1' >OUTPUT/logs-tmp/"$SERIAL"-IPMI-IPAdddress.txt
  IPMIIP=$(cat OUTPUT/logs-tmp/"$SERIAL"-IPMI-IPAdddress.txt)

  # Collecting IPMI MAC address

  grep <OUTPUT/logs-tmp/"$SERIAL"-IPMI-Summary.txt -E -i "BMC MAC Address" | tr -s ' ' | cut -d " " -f5 >OUTPUT/logs-tmp/"$SERIAL"-BMC-MAC.txt
  IPMIMAC=$(cat OUTPUT/logs-tmp/"$SERIAL"-BMC-MAC.txt)

  # Collecting STD info

  psql -h <DB_HOST> -U <DB_USER> -d <DB_NAME> -c "select c.name, a.model, a.serial, a.rma, a.revision, a.support_number from production_part a, production_system b, production_type c, production_configuration d where a.system_id = b.id and a.type_id = c.id and b.config_name_id = d.id and b.system_serial = '$SERIAL' order by b.system_serial, a.type_id, a.model, a.serial;" >OUTPUT/logs-tmp/"$SERIAL"-STD-Parts.txt
  grep <OUTPUT/logs-tmp/"$SERIAL"-STD-Parts.txt "Unique Password" | cut -d "|" -f 3 | xargs >OUTPUT/logs-tmp/"$SERIAL"-IPMI-Password.txt
  IPMIPASSWORD=$(cat OUTPUT/logs-tmp/"$SERIAL"-IPMI-Password.txt)

  # Checking for break-out cable

  grep <OUTPUT/logs-tmp/"$SERIAL"-STD-Parts.txt -i "Break" >OUTPUT/logs-tmp/"$SERIAL"-Network-Cable.txt
  grep <OUTPUT/logs-tmp/"$SERIAL"-STD-Parts.txt -io "Break" >OUTPUT/logs-tmp/"$SERIAL"-Network-Cable-CP.txt
  cut <OUTPUT/logs-tmp/"$SERIAL"-Network-Cable.txt -d "|" -f2 >OUTPUT/logs-tmp/"$SERIAL"-Network-Cable-Model.txt
  cut <OUTPUT/logs-tmp/"$SERIAL"-Network-Cable.txt -d "|" -f3 >OUTPUT/logs-tmp/"$SERIAL"-Network-Cable-Serial.txt
  NETCABCP=$(cat OUTPUT/logs-tmp/"$SERIAL"-Network-Cable-CP.txt)

  if [[ "$NETCABCP" == "Break" ]]; then
    echo "[BREAK-OUT CABLE]" >OUTPUT/logs-tmp/"$SERIAL"-Break-Out.txt
  fi

  BREAKOUT=$(cat OUTPUT/logs-tmp/"$SERIAL"-Break-Out.txt)

  # Getting motherboard manufacturer info

  lynx --dump OUTPUT/logs-tmp/"$SERIAL"-PBS-Passmark_Log.cert.htm | grep -F "Motherboard manufacturer" | xargs | cut -d " " -f 3 >OUTPUT/logs-tmp/"$SERIAL"-Motherboard-Manufacturer.txt
  MOTHERMAN=$(cat OUTPUT/logs-tmp/"$SERIAL"-Motherboard-Manufacturer.txt)

  # Getting system model type

  lynx --dump OUTPUT/logs-tmp/"$SERIAL"-PBS-Passmark_Log.htm | grep -F "System Model:" | head -n 1 >OUTPUT/logs-tmp/"$SERIAL"-System-Model.txt
  cut <OUTPUT/logs-tmp/"$SERIAL"-System-Model.txt -d " " -f19 >OUTPUT/logs-tmp/"$SERIAL"-Model-Type.txt
  MODELTYPE=$(cat OUTPUT/logs-tmp/"$SERIAL"-Model-Type.txt)

  # Checking for wrong memory serial for TrueNAS systems

  curl https://<PBS_ARCHIVE_HOST>/pbsv4/logs/"$SERIAL"/"$PBSDIRECTORY"/DIMM_MemoryChipData.txt -o OUTPUT/logs-tmp/"$SERIAL"-PBS-DIMM_MemoryChipData.txt
  grep <OUTPUT/logs-tmp/"$SERIAL"-PBS-DIMM_MemoryChipData.txt -i "XF" >OUTPUT/logs-tmp/"$SERIAL"-Mem-Check.txt
  MEMSERIALCHECK=$(cat OUTPUT/logs-tmp/"$SERIAL"-Mem-Check.txt)

  if echo "$MEMSERIALCHECK" | grep -F -wqi -e 'XF'; then
    echo "[NVDIMM ERROR]" >OUTPUT/logs-tmp/"$SERIAL"-Mem-Error.txt
  else
    echo "[CORRECT NVDIMM]"
  fi

  MEMERROR=$(cat OUTPUT/logs-tmp/"$SERIAL"-Mem-Error.txt)

  # Check for presence of QLOGIC fibre card

  psql -h <DB_HOST> -U <DB_USER> -d <DB_NAME> -c "select c.name, a.model, a.serial, a.rma, a.revision, a.support_number from production_part a, production_system b, production_type c, production_configuration d where a.system_id = b.id and a.type_id = c.id and b.config_name_id = d.id and b.system_serial = '$SERIAL' order by b.system_serial, a.type_id, a.model, a.serial;" >OUTPUT/logs-tmp/"$SERIAL"-STD-Parts.txt
  grep <OUTPUT/logs-tmp/"$SERIAL"-STD-Parts.txt -i "QLE" | cut -d "|" -f 2 | grep -i -o -P '.{0,0}qle.{0,0}' >OUTPUT/logs-tmp/"$SERIAL"-QLE-Output.txt

  psql -h <DB_HOST> -U <DB_USER> -d <DB_NAME> -c "select c.name, a.model, a.serial, a.rma, a.revision, a.support_number from production_part a, production_system b, production_type c, production_configuration d where a.system_id = b.id and a.type_id = c.id and b.config_name_id = d.id and b.system_serial = '$SERIAL' order by b.system_serial, a.type_id, a.model, a.serial;"

  QLE=$(cat OUTPUT/logs-tmp/"$SERIAL"-QLE-Output.txt)

  if [[ "$QLE" == "QLE" ]]; then

    echo "QLOGIC-CARD-Present-Check-TrueNAS-License" >OUTPUT/logs-tmp/"$SERIAL"-QLOGIC-Check.txt
    echo "[QLOGIC/FC]" >OUTPUT/logs-tmp/"$SERIAL"-QLOGIC-msg.txt
    QLOGIC=$(cat OUTPUT/logs-tmp/"$SERIAL"-QLOGIC-msg.txt)

  fi

  echo "==========================================================================" >>OUTPUT/logs-tmp/Line-Output.txt

  # # Password check
  # if [[ $MODELTYPE != *"X10"* ]] && [[ $MODELTYPE != *"X20"* ]]; then
  #   IPMIUSER=$(cat OUTPUT/logs-tmp/"$SERIAL"-Username.txt)
  #   i=0

  #   until [[ $i -gt 30 ]]; do
  #     ipmitool -I lanplus -H "$IPMIIP" -U "$IPMIUSER" -P "$IPMIPASSWORD" lan print 1 | grep -i "Complete" | tr -s ' ' | cut -d " " -f 6 >OUTPUT/logs-tmp/"$SERIAL"-Passwd-Check.txt
  #     sleep 1
  #     if grep -i Complete <OUTPUT/logs-tmp/"$SERIAL"-Passwd-Check.txt; then
  #       break
  #     fi
  #     ((i++))
  #   done

  #   ipmitool -I lanplus -H "$IPMIIP" -U "$IPMIUSER" -P "$IPMIPASSWORD" lan print 1
  # fi
  # PWD=$(cat OUTPUT/logs-tmp/"$SERIAL"-Passwd-Check.txt)

  # # Verifying password change

  # if [[ "$PWC" == *"Complete"* ]]; then
  #   echo "[PWD VERIFIED]" >OUTPUT/logs-tmp/"$SERIAL"-PWD-Verified.txt
  #   PWDV=$(cat OUTPUT/logs-tmp/"$SERIAL"-PWD-Verified.txt)

  # fi

  # if [[ $MODELTYPE == *"X10"* ]] || [[ $MODELTYPE == *"X20"* ]]; then
  #   IPMIUSER="admin"
  # fi

  # Grabbing LOGS

  mkdir OUTPUT/logs-tmp/PBS_LOGS
  wget -np -r -nH --cut-dirs=4 https://archive.pbs.ixsystems.com/pbsv4/pbs_logs/"$SERIAL"/"$PBSDIRECTORY"/ -P OUTPUT/logs-tmp/PBS_LOGS/"$SERIAL"

  echo "==========================================================================" >>OUTPUT/logs-tmp/Line-Output.txt

  curl https://<PBS_ARCHIVE_HOST>/pbsv4/logs/"$SERIAL"/"$PBSDIRECTORY"/ifconfig.txt -o OUTPUT/logs-tmp/"$SERIAL"-PBS-Interface_Configuration.txt

  curl https://<PBS_ARCHIVE_HOST>/pbsv4/logs/"$SERIAL"/"$PBSDIRECTORY"/ipmi_powersupply_status.txt -o OUTPUT/logs-tmp/"$SERIAL"-PBS-IPMI_Powersupply_Status.txt

  curl https://<PBS_ARCHIVE_HOST>/pbsv4/logs/"$SERIAL"/"$PBSDIRECTORY"/ipmi_sel_list.txt -o OUTPUT/logs-tmp/"$SERIAL"-PBS-IPMI_SEL_List.txt

  curl https://<PBS_ARCHIVE_HOST>/pbsv4/logs/"$SERIAL"/"$PBSDIRECTORY"/ipmi_temperature.txt -o OUTPUT/logs-tmp/"$SERIAL"-PBS-IPMI_Temperature.txt

  curl https://<PBS_ARCHIVE_HOST>/pbsv4/logs/"$SERIAL"/"$PBSDIRECTORY"/WMIC_Bios.txt -o OUTPUT/logs-tmp/"$SERIAL"-PBS-WMIC_BIOS.txt

  curl https://<PBS_ARCHIVE_HOST>/pbsv4/logs/"$SERIAL"/"$PBSDIRECTORY"/wmic_full_information.txt -o OUTPUT/logs-tmp/"$SERIAL"-PBS-WMIC_Full_Information.txt

  curl https://<PBS_ARCHIVE_HOST>/pbsv4/logs/"$SERIAL"/"$PBSDIRECTORY"/DiskDrive_AllInformation.txt -o OUTPUT/logs-tmp/"$SERIAL"-PBS-DiskDrive_AllInformation.txt

  curl https://<PBS_ARCHIVE_HOST>/pbsv4/logs/"$SERIAL"/"$PBSDIRECTORY"/DiskDrive_SerialNumbers.txt -o OUTPUT/logs-tmp/"$SERIAL"-PBS-DiskDrive_SerialNumbers.txt

  curl https://<PBS_ARCHIVE_HOST>/pbsv4/logs/"$SERIAL"/"$PBSDIRECTORY"/Enclosures.txt -o OUTPUT/logs-tmp/"$SERIAL"-PBS-Enclosures.txt

  curl https://<PBS_ARCHIVE_HOST>/pbsv4/logs/"$SERIAL"/"$PBSDIRECTORY"/IP_Address.txt -o OUTPUT/logs-tmp/"$SERIAL"-PBS-IP_Address.txt

  curl https://<PBS_ARCHIVE_HOST>/pbsv4/logs/"$SERIAL"/"$PBSDIRECTORY"/passmark_image.png -o OUTPUT/logs-tmp/"$SERIAL"-PBS-Passmark_Image.png

  echo "==========================================================================" >>OUTPUT/logs-tmp/Line-Output.txt

  # Checking if OOB/DCMS license is needed (Must add work order to TMP folder)

  pdfgrep 'SFT-OOB-LIC' TMP/*.pdf | xargs | cut -d " " -f 1 >OUTPUT/logs-tmp/"$SERIAL"-OOB-Check.txt

  if grep -q "SFT-OOB-LIC" OUTPUT/logs-tmp/"$SERIAL"-OOB-Check.txt; then
    echo "[OOB LICENSE REQUIRED]" >OUTPUT/logs-tmp/"$SERIAL"-OOB-Alert.txt
  fi

  pdfgrep 'SFT-DCMS-SINGLE' TMP/*.pdf | xargs | cut -d " " -f 1 >OUTPUT/logs-tmp/"$SERIAL"-DCMS-Check.txt

  if grep -q "SFT-DCMS-SINGLE" OUTPUT/logs-tmp/"$SERIAL"-DCMS-Check.txt; then
    echo "[DCMS LICENSE REQUIRED]" >OUTPUT/logs-tmp/"$SERIAL"-DCMS-Alert.txt
  fi

  SFTOOB=$(cat OUTPUT/logs-tmp/OOB-Alert.txt)
  SFTDCMS=$(cat OUTPUT/logs-tmp/DCMS-Alert.txt)

  # Grabbing parts lists for DIFF between systems

  touch OUTPUT/logs-tmp/SWQC/"$SERIAL"-PARTS-List.txt
  grep <OUTPUT/logs-tmp/"$SERIAL"-PBS-WMIC_Full_Information.txt -E -i "product=" >OUTPUT/logs-tmp/"$SERIAL"-Motherboard.txt
  {
    echo -e "==========================================================================\n\n"
    echo -e "[MOTHERBOARD]\n-------------\n\n"
    cut <OUTPUT/logs-tmp/"$SERIAL"-Motherboard.txt -d "=" -f 2-
    echo -e "\n"
    echo -e "[CPU]\n-----\n\n"
    lynx --dump OUTPUT/logs-tmp/"$SERIAL"-PBS-Passmark_Log.cert.htm | grep -F "CPU type" | xargs
    echo -e "\n\n"
    echo -e "[MEMORY]\n--------\n\n"
    sed -n -e '/Physical Memory Information:/,/CPU Information:/ p' OUTPUT/logs-tmp/"$SERIAL"-PBS-WMIC_Full_Information.txt | head -n -1
    echo -e "[DRIVES]\n--------\n\n"
    iconv -f UTF-16LE -t UTF-8 OUTPUT/logs-tmp/"$SERIAL"-PBS-DiskDrive_SerialNumbers.txt
    echo -e "=========================================================================="
  } >>OUTPUT/logs-tmp/SWQC/"$SERIAL"-PARTS-List.txt

  # Grabbing Mellanox MAC address for SWQC/Asset List

  touch OUTPUT/logs-tmp/SWQC/"$SERIAL"-MAC-ADDR-List.txt
  {
    echo -e "==========================================================================\n"
    echo -e "$SERIAL MELLANOX CHECK:\n------------------------\n\n"
    grep <OUTPUT/logs-tmp/"$SERIAL"-PBS-Interface_Configuration.txt -i -A3 -B1 mellanox | xargs -0 | sed 's/^ *//g' | sed "/A1-/! s/-//g"
    echo -e "\n==========================================================================\n"
    echo -e "$SERIAL IPMI:\n--------------\n\n"
    grep <OUTPUT/logs-tmp/"$SERIAL"-PBS-IPMI_Summary.txt BMC | sed "s/://g" | sed "/A1-/! s/-//g"
    echo -e "\n==========================================================================\n"
    echo -e "$SERIAL ONBOARD NICS:\n----------------------\n\n"
    grep <OUTPUT/logs-tmp/"$SERIAL"-PBS-Interface_Configuration.txt -E -A5 -i '(Ethernet:|Ethernet 2:)' | xargs -0 | sed 's/^ *//g' | sed "/A1-/! s/-//g"
    echo -e "\n=========================================================================="
  } >>OUTPUT/logs-tmp/SWQC/"$SERIAL"-MAC-ADDR-List.txt

  # MAC address list

  touch OUTPUT/logs-tmp/Full-MAC-Address-List.txt
  {
    echo -e "==========================================================================\n\n"
    echo -e "MAC ADDRESSES FOR $SERIAL\n--------------------------\n\n"
    grep <OUTPUT/logs-tmp/"$SERIAL"-PBS-Interface_Configuration.txt -E -iB5 "physical Address" | grep -E -iv "media disconnected|connection specific" | sed "/A1-/! s/-//g"
    echo -e "\n"
    grep <OUTPUT/logs-tmp/"$SERIAL"-PBS-IPMI_Summary.txt -i BMC | sed "s/://g" | sed "/A1-/! s/-//g"
    echo -e "\n"
    echo -e "==========================================================================\n"
  } >>OUTPUT/logs-tmp/Full-MAC-Address-List.txt
  sed <OUTPUT/logs-tmp/Full-MAC-Address-List.txt 's/^ *//g' >OUTPUT/logs-tmp/SWQC/"$ORDER"-MAC-LIST.txt

  echo "==========================================================================" >>OUTPUT/logs-tmp/Line-Output.txt

  # # Grabbing SEL, SDR, & SENSOR info
  # if [[ $MODELTYPE != *"X10"* ]] && [[ $MODELTYPE != *"X20"* ]]; then
  #   i=0

  #   until [[ $i -gt 30 ]]; do
  #     ipmitool -I lanplus -H "$IPMIIP" -U "$IPMIUSER" -P "$IPMIPASSWORD" sdr list >OUTPUT/logs-tmp/"$SERIAL"-SDR-Data.txt
  #     sleep 1
  #     if grep -i ok <OUTPUT/logs-tmp/"$SERIAL"-SDR-Data.txt; then
  #       break
  #     fi
  #     ((i++))
  #   done

  #   ipmitool -I lanplus -H "$IPMIIP" -U "$IPMIUSER" -P "$IPMIPASSWORD" sdr list >OUTPUT/logs-tmp/"$SERIAL"-SDR-Data.txt
  #   ipmitool -I lanplus -H "$IPMIIP" -U "$IPMIUSER" -P "$IPMIPASSWORD" sdr list

  #   i=0

  #   until [[ $i -gt 5 ]]; do
  #     ipmitool -I lanplus -H "$IPMIIP" -U "$IPMIUSER" -P "$IPMIPASSWORD" sel list >OUTPUT/logs-tmp/"$SERIAL"-SEL-Data.txt
  #     sleep 1
  #     if ipmitool -I lanplus -H "$IPMIIP" -U "$IPMIUSER" -P "$IPMIPASSWORD" sel list; then
  #       break
  #     fi
  #     ((i++))
  #   done

  #   ipmitool -I lanplus -H "$IPMIIP" -U "$IPMIUSER" -P "$IPMIPASSWORD" sel list

  #   i=0

  #   until [[ $i -gt 5 ]]; do
  #     ipmitool -I lanplus -H "$IPMIIP" -U "$IPMIUSER" -P "$IPMIPASSWORD" sensor list >OUTPUT/logs-tmp/"$SERIAL"-SENSOR-Data.txt
  #     sleep 1
  #     if grep -i ok <OUTPUT/logs-tmp/"$SERIAL"-SENSOR-Data.txt; then
  #       break
  #     fi
  #     ((i++))
  #   done

  #   ipmitool -I lanplus -H "$IPMIIP" -U "$IPMIUSER" -P "$IPMIPASSWORD" sensor list

  #   # Get LINE count for SDR OK

  #   i=0

  #   until [[ $i -gt 5 ]]; do
  #     ipmitool -I lanplus -H "$IPMIIP" -U "$IPMIUSER" -P "$IPMIPASSWORD" sdr list | grep -ic ok >OUTPUT/logs-tmp/"$SERIAL"-SDR-OK.txt
  #     sleep 1
  #     if [[ -s OUTPUT/logs-tmp/"$SERIAL"-SDR-OK.txt ]]; then
  #       break
  #     fi
  #     ((i++))
  #   done

  #   # Get FRU info

  #   i=0

  #   until [[ $i -gt 5 ]]; do
  #     ipmitool -I lanplus -H "$IPMIIP" -U "$IPMIUSER" -P "$IPMIPASSWORD" fru print 0 | grep -iE "Board Mfg|Board Product|Product Manufacturer|Product Name|Product Serial" >OUTPUT/logs-tmp/"$SERIAL"-FRU.txt
  #     sleep 1
  #     if grep -i product <OUTPUT/logs-tmp/"$SERIAL"-FRU.txt; then
  #       break
  #     fi
  #     ((i++))
  #   done

  #   ipmitool -I lanplus -H "$IPMIIP" -U "$IPMIUSER" -P "$IPMIPASSWORD" fru print 0
  # fi
  echo "==========================================================================" >>OUTPUT/logs-tmp/Line-Output.txt

  # Check for missing fans for IX-4224GP2-IXN model

  if [[ "$MODELTYPE" == @(IX-4224GP2-IXN) ]]; then
    grep <OUTPUT/logs-tmp/"$SERIAL"-SDR-Data.txt -i -v "FAN10" | grep -i 'FAN[17]' >OUTPUT/logs-tmp/"$SERIAL"-FAN-Data.txt

  elif grep <OUTPUT/logs-tmp/"$SERIAL"-FAN-Data.txt "no reading"; then
    echo "[CHECK FANS]" >OUTPUT/logs-tmp/"$SERIAL"-FAN-Check.txt
  fi

  FANERROR=$(cat OUTPUT/logs-tmp/"$SERIAL"-FAN-Check.txt)

  # Dumping data to consolidate output file

  echo "$SERIAL,$IPMIIP,$IPMIMAC,$PASSVER,$DISK00PF,$TESTDURATION,$IPMIPASSWORD,$PWDV,$MOTHERMAN,$MODELTYPE,$BREAKOUT,$MEMERROR,$CPUTEMP,$NOCPUTEMP,$QLOGIC,$SFTOOB,$SFTDCMS,$FANERROR" | xargs >>OUTPUT/logs-tmp/CC/"$ORDER"-PBS-OUTPUT.txt

  {
    echo -e "------------------------------------$ORDER------------------------------------\n\n"
    echo -e "==========================================================================="
    echo -e "SERIAL NUMBER:\n$SERIAL"
    echo -e "==========================================================================="
    echo -e "IPMI IP:\n$IPMIIP"
    echo -e "==========================================================================="
    echo -e "IPMI USER:\n$IPMIUSER"
    echo -e "==========================================================================="
    echo -e "IPMI PASSWORD:\n$IPMIPASSWORD\n$PWDV"
    echo -e "==========================================================================="
    echo -e "IPMI MAC ADDRESS:\n$IPMIMAC"
    echo -e "==========================================================================="
    echo -e "BURN-IN RESULTS:\n$PASSVER\n$DISK00PF\n$TESTDURATION\n\n$CERT"
    echo -e "==========================================================================="
    echo -e "SYSTEM INFO:\n$MOTHERMAN\n$MODELTYPE"
    echo -e "==========================================================================="
    echo -e "CONFIGURATIONS:\n$NETSET\n$FANSET"
    echo -e "==========================================================================="
    echo -e "SYSTEM WARNINGS:\n$CPUTEMP\n$MEMERROR\n$NOCPUTEMP\n$BREAKOUT\n$QLOGIC\n$FANERROR\n$MINIEFANERROR\n$SFTOOB\n$SFTDCMS\n$INLET"
  } >>OUTPUT/logs-tmp/"$ORDER"-REPORT.txt

  echo "$SERIAL $IPMIIP $IPMIUSER $IPMIPASSWORD $IPMIMAC" >>OUTPUT/logs-tmp/IPMI.txt

done

# Creating CSV file for data transfer

tr -s " " <OUTPUT/logs-tmp/IPMI.txt >OUTPUT/logs-tmp/CC/"$ORDER"-IPMI.csv

echo "==========================================================================" >>OUTPUT/logs-tmp/Line-Output.txt

# Creating GOLD file for diff

LINE=$(head -n 1 OUTPUT/logs-tmp/Input.txt)

cp OUTPUT/logs-tmp/"$LINE"-SEL-Data.txt OUTPUT/logs-tmp/SWQC/GOLD-SEL-Data.txt
cp OUTPUT/logs-tmp/"$LINE"-SDR-Data.txt OUTPUT/logs-tmp/SWQC/GOLD-SDR-Data.txt
cp OUTPUT/logs-tmp/"$LINE"-SENSOR-Data.txt OUTPUT/logs-tmp/SWQC/GOLD-SENSOR-Data.txt
cp OUTPUT/logs-tmp/SWQC/"$LINE"-PARTS-List.txt OUTPUT/logs-tmp/SWQC/GOLD-PARTS-List.txt
cp OUTPUT/logs-tmp/"$LINE"-SDR-OK.txt OUTPUT/logs-tmp/SWQC/GOLD-SDR-OK.txt
cp OUTPUT/logs-tmp/"$LINE"-FRU.txt OUTPUT/logs-tmp/SWQC/GOLD-FRU.txt

# Diffing each system for errors

FILE=OUTPUT/logs-tmp/Input.txt
SERIAL=""
exec 3<&0
exec 0<"$FILE"
while read -r LINE; do
  SERIAL=$(echo "$LINE" | cut -d " " -f 1)

  echo "------------------------------------------------------$SERIAL------------------------------------------------------" >>OUTPUT/logs-tmp/SWQC/"$ORDER"-SEL-DIFF.txt
  diff -y -W 200 --suppress-common-lines OUTPUT/logs-tmp/SWQC/GOLD-SEL-Data.txt OUTPUT/logs-tmp/"$SERIAL"-SEL-Data.txt >>OUTPUT/logs-tmp/SWQC/"$ORDER"-SEL-DIFF.txt

  echo "------------------------------------------------------$SERIAL------------------------------------------------------" >>OUTPUT/logs-tmp/SWQC/"$ORDER"-SDR-DIFF.txt
  diff -y -W 200 --suppress-common-lines OUTPUT/logs-tmp/SWQC/GOLD-SDR-Data.txt OUTPUT/logs-tmp/"$SERIAL"-SDR-Data.txt >>OUTPUT/logs-tmp/SWQC/"$ORDER"-SDR-DIFF.txt

  echo "------------------------------------------------------$SERIAL------------------------------------------------------" >>OUTPUT/logs-tmp/SWQC/"$ORDER"-SENSOR-DIFF.txt
  diff -y -W 200 --suppress-common-lines OUTPUT/logs-tmp/SWQC/GOLD-SENSOR-Data.txt OUTPUT/logs-tmp/"$SERIAL"-SENSOR-Data.txt >>OUTPUT/logs-tmp/SWQC/"$ORDER"-SENSOR-DIFF.txt

  echo "------------------------------------------------------$SERIAL------------------------------------------------------" >>OUTPUT/logs-tmp/SWQC/"$ORDER"-PARTS-DIFF.txt
  diff -y -W 200 --suppress-common-lines OUTPUT/logs-tmp/SWQC/GOLD-PARTS-List.txt OUTPUT/logs-tmp/SWQC/"$SERIAL"-PARTS-List.txt >>OUTPUT/logs-tmp/SWQC/"$ORDER"-PARTS-DIFF.txt

  echo "------------------------------------------------------$SERIAL------------------------------------------------------" >>OUTPUT/logs-tmp/SWQC/"$ORDER"-SDR-OK-DIFF.txt
  diff -y -W 200 --suppress-common-lines OUTPUT/logs-tmp/SWQC/GOLD-SDR-OK.txt OUTPUT/logs-tmp/"$SERIAL"-SDR-OK.txt >>OUTPUT/logs-tmp/SWQC/"$ORDER"-SDR-OK-DIFF.txt

  echo "------------------------------------------------------$SERIAL------------------------------------------------------" >>OUTPUT/logs-tmp/SWQC/"$ORDER"-FRU-DIFF.txt
  diff -y -W 200 --suppress-common-lines OUTPUT/logs-tmp/SWQC/GOLD-FRU.txt OUTPUT/logs-tmp/"$SERIAL"-FRU.txt >>OUTPUT/logs-tmp/SWQC/"$ORDER"-FRU-DIFF.txt

done

echo "=====================================END=====================================" >>OUTPUT/logs-tmp/Line-Output.txt

column <OUTPUT/logs-tmp/CC/"$ORDER"-PBS-OUTPUT.txt -t -s "," -o " " >OUTPUT/logs-tmp/CC/"$ORDER"-PBS-OUT.txt
cp OUTPUT/logs-tmp/SWQC/GOLD-SDR-Data.txt OUTPUT/logs-tmp/CC
cp OUTPUT/logs-tmp/SWQC/"$ORDER"-SDR-DIFF.txt OUTPUT/logs-tmp/CC
mv OUTPUT/logs-tmp/"$SERIAL"-QLOGIC-Check.txt OUTPUT/logs-tmp/SWQC
mv OUTPUT/logs-tmp/SWQC/"$SERIAL"-MAC-ADDR-List.txt OUTPUT/logs-tmp/SWQC/"$ORDER"-MELLANOX-LIST.txt
mv OUTPUT/logs-tmp/"$ORDER"-REPORT.txt OUTPUT/logs-tmp/CC
rm OUTPUT/logs-tmp/CC/"$ORDER"-PBS-OUTPUT.txt
mv OUTPUT/logs-tmp OUTPUT/"$ORDER"-TEST-LOGS
rm -rf TMP/*.pdf

# Compress output file

tar cfz OUTPUT/"$ORDER-TEST-LOGS.tar.gz" OUTPUT/"$ORDER"-TEST-LOGS

exit
