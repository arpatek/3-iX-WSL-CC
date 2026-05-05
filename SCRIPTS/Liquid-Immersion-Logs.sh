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
# 6. The byte order mark (BOM) may be set. Vi KEY.txt after entering your information you will see an ^M. Uncheck byte order mark in your txt editor. Re-enter info.
# 7. In your txt editor go to tools and change End of line to Unix.
# 8. When inputing serials on KEY.txt leave a blank line at end of document otherwise last line won't be read.
# 9. Sometimes when PBS logs are missing some information we use for our variables, it can cause the script to fail
#########################################################################################################

# Removing previous temp folder

rm -rf OUTPUT/liquid-tmp

# This is the directories where the data we collect will go

mkdir OUTPUT/liquid-tmp
mkdir OUTPUT/liquid-tmp/SWQC
mkdir OUTPUT/liquid-tmp/CC

# Collecting name of person performing CC

dialog --inputbox "Enter The Name Of The Person Performing CC Here" 10 60 2>OUTPUT/liquid-tmp/CC-Person.txt
CCPERSON=$(tr <OUTPUT/liquid-tmp/CC-Person.txt '[:lower:]' '[:upper:]')

# Collecting order number for systems

dialog --inputbox "Enter Order Number" 10 60 2>OUTPUT/liquid-tmp/Order-Num.txt
ORDER=$(cat OUTPUT/liquid-tmp/Order-Num.txt)

# Removing previous files

rm -rf OUTPUT/"$ORDER"-HRT-Liquid-Immersion-Logs.tar.gz OUTPUT/"$ORDER"-HRT-Liquid-Immersion-Logs
clear

echo "==========================================================================" >>OUTPUT/liquid-tmp/Line-Output.txt

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
} >>OUTPUT/liquid-tmp/"$ORDER"-REPORT.txt

# Grabbring serial number from KEY.txt

cp ~/3-iX-WSL-CC/SCRIPTS/KEY.txt OUTPUT/liquid-tmp/Input.txt

FILE=OUTPUT/liquid-tmp/Input.txt
SERIAL=""
exec 3<&0
exec 0<"$FILE"
while read -r LINE; do
  SERIAL=$(echo "$LINE" | cut -d " " -f1)

  touch OUTPUT/liquid-tmp/CC/"$ORDER"-PBS-OUTPUT.txt
  touch OUTPUT/liquid-tmp/"$SERIAL"-Username.txt
  touch OUTPUT/liquid-tmp/IPMI.txt

  echo "==========================================================================" >>OUTPUT/liquid-tmp/Line-Output.txt

  # Grabbing Burn-In information from PBS logs

  lynx --dump https://archive.net/bsv4/logs/"$SERIAL"/ | tail -1 | cut -d "/" -f7 >OUTPUT/liquid-tmp/"$SERIAL"-DIR.txt
  PBSDIRECTORY=$(cat OUTPUT/liquid-tmp/"$SERIAL"-DIR.txt)
  curl https://archive.net/bsv4/logs/"$SERIAL"/"$PBSDIRECTORY"/ipmi_summary.txt -o OUTPUT/liquid-tmp/"$SERIAL"-PBS-IPMI_Summary.txt

  if PBSDIRECTORY=$(cat OUTPUT/liquid-tmp/"$SERIAL"-DIR.txt); then
    echo "$PBSDIRECTORY" >OUTPUT/liquid-tmp/"$SERIAL"-DIR-Check.txt
    curl https://archive.net/bsv4/logs/"$SERIAL"/"$PBSDIRECTORY"/ipmi_summary.txt -o OUTPUT/liquid-tmp/"$SERIAL"-PBS-IPMI_Summary.txt

  fi

  # Grabbing Passmark Log

  curl https://archive.net/bsv4/logs/"$SERIAL"/"$PBSDIRECTORY"/Passmark_Log.cert.htm -o OUTPUT/liquid-tmp/"$SERIAL"-PBS-Passmark_Log.cert.htm
  lynx --dump OUTPUT/liquid-tmp/"$SERIAL"-PBS-Passmark_Log.cert.htm >OUTPUT/liquid-tmp/"$SERIAL"-Lynx-Cert.txt
  cat OUTPUT/liquid-tmp/"$SERIAL"-Lynx-Cert.txt
  lynx --dump OUTPUT/liquid-tmp/"$SERIAL"-PBS-Passmark_Log.cert.htm | grep -F "TEST RUN" >OUTPUT/liquid-tmp/"$SERIAL"-Test-Run.txt
  tr -s ' ' <OUTPUT/liquid-tmp/"$SERIAL"-Test-Run.txt | cut -d ' ' -f 4 | awk '{$1=$1};1' >OUTPUT/liquid-tmp/"$SERIAL"-PF.txt
  PASSFAIL=$(cat OUTPUT/liquid-tmp/"$SERIAL"-PF.txt)

  if [[ "$PASSFAIL" == "PASSED" ]]; then
    echo "[PASSED]" >OUTPUT/liquid-tmp/"$SERIAL"-Passed.txt
  elif [[ "$PASSFAIL" == "FAILED" ]]; then
    echo "[FAILED]" >OUTPUT/liquid-tmp/"$SERIAL"-Passed.txt
  fi

  PASSVER=$(cat OUTPUT/liquid-tmp/"$SERIAL"-Passed.txt)

  curl https://archive.net/bsv4/logs/"$SERIAL"/"$PBSDIRECTORY"/Passmark_Log.htm -o OUTPUT/liquid-tmp/"$SERIAL"-PBS-Passmark_Log.htm
  echo -e "https://archive.net/bsv4/logs/$SERIAL/$PBSDIRECTORY/Passmark_Log.cert.htm" >OUTPUT/liquid-tmp/"$SERIAL"-CERT.txt
  CERT=$(cat OUTPUT/liquid-tmp/"$SERIAL"-CERT.txt)

  # CPU presence check

  lynx --dump OUTPUT/liquid-tmp/"$SERIAL"-PBS-Passmark_Log.cert.htm | grep -E -i 'CPU 0|CPU 1' >OUTPUT/liquid-tmp/"$SERIAL"-CPU-Presence.txt
  if ! [ -s OUTPUT/liquid-tmp/"$SERIAL"-CPU-Presence.txt ]; then
    echo "[NO CPU TEMP DETECTED]" >OUTPUT/liquid-tmp/"$SERIAL"-NO-CPU-Presence.txt
  fi

  NOCPUTEMP=$(cat OUTPUT/liquid-tmp/"$SERIAL"-NO-CPU-Presence.txt)

  # CPU temp check

  lynx --dump OUTPUT/liquid-tmp/"$SERIAL"-PBS-Passmark_Log.cert.htm | grep -E -i 'CPU 0|CPU 1' | xargs >OUTPUT/liquid-tmp/"$SERIAL"-CPU-Temp.txt
  cut <OUTPUT/liquid-tmp/"$SERIAL"-CPU-Temp.txt -d " " -f5 | cut -c 1-2 >OUTPUT/liquid-tmp/"$SERIAL"-CPU-Max.txt
  read -r num <OUTPUT/liquid-tmp/"$SERIAL"-CPU-Max.txt
  if [[ "$num" -gt 89 ]]; then
    echo "[CPU TEMP ABOVE THRESHOLD]" >OUTPUT/liquid-tmp/"$SERIAL"-CPU-Error.txt
  else
    echo "[CPU TEMP OK]"
  fi

  CPUTEMP=$(cat OUTPUT/liquid-tmp/"$SERIAL"-CPU-Error.txt)

  # Checking to ensure system ran with test disk

  lynx --dump OUTPUT/liquid-tmp/"$SERIAL"-PBS-Passmark_Log.cert.htm | grep -F "Disk (0)" | awk '{$1=$1};1' >OUTPUT/liquid-tmp/"$SERIAL"-Disk00-pf.txt
  DISK0PF=$(cat OUTPUT/liquid-tmp/"$SERIAL"-Disk00-pf.txt)

  # Collecting test duration

  lynx --dump OUTPUT/liquid-tmp/"$SERIAL"-PBS-Passmark_Log.cert.htm | grep -F "Test Duration" | awk '{$1=$1};1' >OUTPUT/liquid-tmp/"$SERIAL"-Test-Duration-pf.txt
  TESTDURATION=$(cat OUTPUT/liquid-tmp/"$SERIAL"-Test-Duration-pf.txt)

  # Collecting IPMI IP address

  sed -e "s/\r//g" OUTPUT/liquid-tmp/"$SERIAL"-PBS-IPMI_Summary.txt >OUTPUT/liquid-tmp/"$SERIAL"-IPMI-Summary.txt

  grep <OUTPUT/liquid-tmp/"$SERIAL"-IPMI-Summary.txt -E -i "IPv4 Address           : " | cut -d ":" -f 2 | awk '{$1=$1};1' >OUTPUT/liquid-tmp/"$SERIAL"-IPMI-IPAdddress.txt
  IPMIIP=$(cat OUTPUT/liquid-tmp/"$SERIAL"-IPMI-IPAdddress.txt)

  # Collecting IPMI MAC address

  grep <OUTPUT/liquid-tmp/"$SERIAL"-IPMI-Summary.txt -E -i "BMC MAC Address        : " >OUTPUT/liquid-tmp/"$SERIAL"-IPMI-BMC-MAC.txt
  tr -s ' ' <OUTPUT/liquid-tmp/"$SERIAL"-IPMI-BMC-MAC.txt | cut -d ' ' -f 5 >OUTPUT/liquid-tmp/"$SERIAL"-BMC-MAC.txt
  IPMIMAC=$(cat OUTPUT/liquid-tmp/"$SERIAL"-BMC-MAC.txt)

  # Collecting STD info

  psql -h <DB_HOST> -U <DB_USER> -d <DB_NAME> -c "select c.name, a.model, a.serial, a.rma, a.revision, a.support_number from production_part a, production_system b, production_type c, production_configuration d where a.system_id = b.id and a.type_id = c.id and b.config_name_id = d.id and b.system_serial = '$SERIAL' order by b.system_serial, a.type_id, a.model, a.serial;" >OUTPUT/liquid-tmp/"$SERIAL"-STD-Parts.txt
  grep <OUTPUT/liquid-tmp/"$SERIAL"-STD-Parts.txt "Unique Password" | cut -d "|" -f 3 | xargs >OUTPUT/liquid-tmp/"$SERIAL"-IPMI-Password.txt
  IPMIPASSWORD="password"

  # Checking for break-out cable

  grep <OUTPUT/liquid-tmp/"$SERIAL"-STD-Parts.txt -i "Break" >OUTPUT/liquid-tmp/"$SERIAL"-Network-Cable.txt
  grep <OUTPUT/liquid-tmp/"$SERIAL"-STD-Parts.txt -io "Break" >OUTPUT/liquid-tmp/"$SERIAL"-Network-Cable-CP.txt
  cut <OUTPUT/liquid-tmp/"$SERIAL"-Network-Cable.txt -d "|" -f2 >OUTPUT/liquid-tmp/"$SERIAL"-Network-Cable-Model.txt
  cut <OUTPUT/liquid-tmp/"$SERIAL"-Network-Cable.txt -d "|" -f3 >OUTPUT/liquid-tmp/"$SERIAL"-Network-Cable-Serial.txt
  NETCABCP=$(cat OUTPUT/liquid-tmp/"$SERIAL"-Network-Cable-CP.txt)

  if [[ "$NETCABCP" == "Break" ]]; then
    echo "[BREAK-OUT CABLE]" >OUTPUT/liquid-tmp/"$SERIAL"-Break-Out.txt
  fi

  BREAKOUT=$(cat OUTPUT/liquid-tmp/"$SERIAL"-Break-Out.txt)

  # Getting motherboard manufacturer info

  lynx --dump OUTPUT/liquid-tmp/"$SERIAL"-PBS-Passmark_Log.cert.htm | grep -F "Motherboard manufacturer" | xargs | cut -d " " -f 3- >OUTPUT/liquid-tmp/"$SERIAL"-Motherboard-Manufacturer.txt
  MOTHERMAN=$(cat OUTPUT/liquid-tmp/"$SERIAL"-Motherboard-Manufacturer.txt)

  # Getting system model type

  lynx --dump OUTPUT/liquid-tmp/"$SERIAL"-PBS-Passmark_Log.htm | grep -F "System Model:" | head -n 1 >OUTPUT/liquid-tmp/"$SERIAL"-System-Model.txt
  cut <OUTPUT/liquid-tmp/"$SERIAL"-System-Model.txt -d " " -f19 >OUTPUT/liquid-tmp/"$SERIAL"-Model-Type.txt
  MODELTYPE=$(cat OUTPUT/liquid-tmp/"$SERIAL"-Model-Type.txt)

  # Checking for wrong memory serial for TrueNAS systems

  curl https://archive.net/bsv4/logs/"$SERIAL"/"$PBSDIRECTORY"/DIMM_MemoryChipData.txt -o OUTPUT/liquid-tmp/"$SERIAL"-PBS-DIMM_MemoryChipData.txt
  grep <OUTPUT/liquid-tmp/"$SERIAL"-PBS-DIMM_MemoryChipData.txt -i "XF" >OUTPUT/liquid-tmp/"$SERIAL"-Mem-Check.txt
  MEMSERIALCHECK=$(cat OUTPUT/liquid-tmp/"$SERIAL"-Mem-Check.txt)

  if echo "$MEMSERIALCHECK" | grep -F -wqi -e 'XF'; then
    echo "[NVDIMM ERROR]" >OUTPUT/liquid-tmp/"$SERIAL"-Mem-Error.txt
  else
    echo "[CORRECT NVDIMM]"
  fi

  MEMERROR=$(cat OUTPUT/liquid-tmp/"$SERIAL"-Mem-Error.txt)

  # Check for presence of QLOGIC fibre card

  psql -h <DB_HOST> -U <DB_USER> -d <DB_NAME> -c "select c.name, a.model, a.serial, a.rma, a.revision, a.support_number from production_part a, production_system b, production_type c, production_configuration d where a.system_id = b.id and a.type_id = c.id and b.config_name_id = d.id and b.system_serial = '$SERIAL' order by b.system_serial, a.type_id, a.model, a.serial;" >OUTPUT/liquid-tmp/"$SERIAL"-STD-Parts.txt
  grep <OUTPUT/liquid-tmp/"$SERIAL"-STD-Parts.txt -i "QLE" | cut -d "|" -f 2 | grep -i -o -P '.{0,0}qle.{0,0}' >OUTPUT/liquid-tmp/"$SERIAL"-QLE-Output.txt

  psql -h <DB_HOST> -U <DB_USER> -d <DB_NAME> -c "select c.name, a.model, a.serial, a.rma, a.revision, a.support_number from production_part a, production_system b, production_type c, production_configuration d where a.system_id = b.id and a.type_id = c.id and b.config_name_id = d.id and b.system_serial = '$SERIAL' order by b.system_serial, a.type_id, a.model, a.serial;"

  QLE=$(cat OUTPUT/liquid-tmp/"$SERIAL"-QLE-Output.txt)

  if [[ "$QLE" == "QLE" ]]; then

    echo "QLOGIC-CARD-Present-Check-TrueNAS-License" >OUTPUT/liquid-tmp/"$SERIAL"-QLOGIC-Check.txt
    echo "[QLOGIC/FC]" >OUTPUT/liquid-tmp/"$SERIAL"-QLOGIC-msg.txt
    QLOGIC=$(cat OUTPUT/liquid-tmp/"$SERIAL"-QLOGIC-msg.txt)

  fi

  IPMIUSER="admin"
  ipmitool -I lanplus -H "$IPMIIP" -U "$IPMIUSER" -P "$IPMIPASSWORD" lan print 1 | grep -i "Complete" | tr -s ' ' | cut -d " " -f 6 >OUTPUT/liquid-tmp/"$SERIAL"-Passwd-Check.txt
  PWC=$(cat OUTPUT/liquid-tmp/"$SERIAL"-Passwd-Check.txt)
  ipmitool -I lanplus -H "$IPMIIP" -U "$IPMIUSER" -P "$IPMIPASSWORD" lan print 1

  if [[ "$PWC" == *"Complete"* ]]; then
    echo "[PWD VERIFIED]" >OUTPUT/liquid-tmp/"$SERIAL"-PWD-Verified.txt
    PWDV=$(cat OUTPUT/liquid-tmp/"$SERIAL"-PWD-Verified.txt)

  fi

  echo "==========================================================================" >>OUTPUT/liquid-tmp/Line-Output.txt

  curl https://archive.net/bsv4/logs/"$SERIAL"/"$PBSDIRECTORY"/ipconfig.txt -o OUTPUT/liquid-tmp/"$SERIAL"-PBS-IFCONFIG.txt

  curl https://archive.net/bsv4/logs/"$SERIAL"/"$PBSDIRECTORY"/ipmi_powersupply_status.txt -o OUTPUT/liquid-tmp/"$SERIAL"-PBS-IPMI_Powersupply_Status.txt

  curl https://archive.net/bsv4/logs/"$SERIAL"/"$PBSDIRECTORY"/ipmi_sel_list.txt -o OUTPUT/liquid-tmp/"$SERIAL"-PBS-IPMI_SEL_List.txt

  curl https://archive.net/bsv4/logs/"$SERIAL"/"$PBSDIRECTORY"/ipmi_temperature.txt -o OUTPUT/liquid-tmp/"$SERIAL"-PBS-IPMI_Temperature.txt

  curl https://archive.net/bsv4/logs/"$SERIAL"/"$PBSDIRECTORY"/WMIC_BIOS.txt -o OUTPUT/liquid-tmp/"$SERIAL"-PBS-WMIC_BIOS.txt

  curl https://archive.net/bsv4/logs/"$SERIAL"/"$PBSDIRECTORY"/WMIC_Full_Information.txt -o OUTPUT/liquid-tmp/"$SERIAL"-PBS-WMIC_Full_Information.txt

  curl https://archive.net/bsv4/logs/"$SERIAL"/"$PBSDIRECTORY"/WMIC_MemoryChip.txt -o OUTPUT/liquid-tmp/"$SERIAL"-PBS-WMIC_MemoryChip.txt

  curl https://archive.net/bsv4/logs/"$SERIAL"/"$PBSDIRECTORY"/WMIC_DiskDrive.txt -o OUTPUT/liquid-tmp/"$SERIAL"-PBS-WMIC_DiskDrive.txt

  curl https://archive.net/bsv4/logs/"$SERIAL"/"$PBSDIRECTORY"/WMIC_NIC.txt -o OUTPUT/liquid-tmp/"$SERIAL"-PBS-WMIC_NIC.txt

  curl https://archive.net/bsv4/logs/"$SERIAL"/"$PBSDIRECTORY"/IP_Address.txt -o OUTPUT/liquid-tmp/"$SERIAL"-PBS-IP_Address.txt

  curl https://<PBS_ARCHIVE_HOST>/pbsv4/logs/"$SERIAL"/"$PBSDIRECTORY"/passmark_image.png -o OUTPUT/liquid-tmp/"$SERIAL"-PBS-Passmark_Image.png

  curl https://<PBS_ARCHIVE_HOST>/pbsv4/logs/"$SERIAL"/"$PBSDIRECTORY"/WMIC_CPU.txt -o OUTPUT/liquid-tmp/"$SERIAL"-PBS-WMIC_CPU.txt

  curl https://<PBS_ARCHIVE_HOST>/pbsv4/logs/"$SERIAL"/"$PBSDIRECTORY"/WMIC_Baseboard.txt -o OUTPUT/liquid-tmp/"$SERIAL"-PBS-WMIC_Baseboard.txt

  curl https://<PBS_ARCHIVE_HOST>/pbsv4/logs/"$SERIAL"/"$PBSDIRECTORY"/WMIC_BIOS.txt -o OUTPUT/liquid-tmp/"$SERIAL"-PBS-WMIC_BIOS.txt

  curl https://<PBS_ARCHIVE_HOST>/pbsv4/logs/"$SERIAL"/"$PBSDIRECTORY"/WMIC_Device.txt -o OUTPUT/liquid-tmp/"$SERIAL"-PBS-WMIC_Device.txt

  echo "==========================================================================" >>OUTPUT/liquid-tmp/Line-Output.txt

  # Checking if OOB/DCMS license is needed (Must add work order to TMP folder)

  pdfgrep 'SFT-OOB-LIC' TMP/*.pdf | xargs | cut -d " " -f 1 >OUTPUT/liquid-tmp/OOB-Check.txt

  if grep -q "SFT-OOB-LIC" "OUTPUT/liquid-tmp/OOB-Check.txt"; then
    echo "[OOB LICENSE REQUIRED]" >OUTPUT/liquid-tmp/OOB-Alert.txt
  fi

  pdfgrep 'SFT-DCMS-SINGLE' TMP/*.pdf | xargs | cut -d " " -f 1 >OUTPUT/liquid-tmp/DCMS-Check.txt

  if grep -q "SFT-DCMS-SINGLE" "OUTPUT/liquid-tmp/DCMS-Check.txt"; then
    echo "[DCMS LICENSE REQUIRED]" >OUTPUT/liquid-tmp/DCMS-Alert.txt
  fi

  SFTOOB=$(cat OUTPUT/liquid-tmp/OOB-Alert.txt)
  SFTDCMS=$(cat OUTPUT/liquid-tmp/DCMS-Alert.txt)

  # Grabbing parts lists for DIFF between systems

  touch OUTPUT/liquid-tmp/SWQC/"$SERIAL"-PARTS-List.txt
  grep <OUTPUT/liquid-tmp/"$SERIAL"-PBS-WMIC_Full_Information.txt -E -i "product=" >OUTPUT/liquid-tmp/"$SERIAL"-Motherboard.txt
  {
    echo -e "$SERIAL PARTS LIST\n-------------------\n\n\n"
    echo -e "\n[MOTHERBOARD]\n-------------\n"
    iconv -f UTF-16LE -t UTF-8 OUTPUT/liquid-tmp/"$SERIAL"-PBS-WMIC_Baseboard.txt
    echo -e "\n[BIOS]\n------\n"
    iconv -f UTF-16LE -t UTF-8 OUTPUT/liquid-tmp/"$SERIAL"-PBS-WMIC_BIOS.txt
    echo -e "\n[CPU]\n-----\n"
    iconv -f UTF-16LE -t UTF-8 OUTPUT/liquid-tmp/"$SERIAL"-PBS-WMIC_CPU.txt
    echo -e "\n[MEMORY]\n--------\n"
    iconv -f UTF-16LE -t UTF-8 OUTPUT/liquid-tmp/"$SERIAL"-PBS-WMIC_MemoryChip.txt
    echo -e "\n[DRIVES]\n--------\n"
    iconv -f UTF-16LE -t UTF-8 OUTPUT/liquid-tmp/"$SERIAL"-PBS-WMIC_DiskDrive.txt
    echo -e "\n[NIC]\n-----\n"
    iconv -f UTF-16LE -t UTF-8 OUTPUT/liquid-tmp/"$SERIAL"-PBS-WMIC_NIC.txt
    echo -e "\n[DEVICE]\n--------\n"
    iconv -f UTF-16LE -t UTF-8 OUTPUT/liquid-tmp/"$SERIAL"-PBS-WMIC_Device.txt
    echo -e "\n=========================================================================================================================="
  } >>OUTPUT/liquid-tmp/SWQC/"$SERIAL"-PARTS-List.txt

  # Grabbing Mellanox MAC address for SWQC/Asset List

  touch OUTPUT/liquid-tmp/SWQC/MAC-ADDR-List.txt
  {
    echo -e "==========================================================================\n"
    echo -e "$SERIAL MELLANOX CHECK:\n------------------------\n\n"
    grep <OUTPUT/liquid-tmp/"$SERIAL"-PBS-IFCONFIG.txt -i -A3 -B1 mellanox | xargs -0 | sed 's/^ *//g' | sed "/A1-/! s/-//g"
    echo -e "\n==========================================================================\n"
    echo -e "$SERIAL IPMI:\n--------------\n\n"
    grep <OUTPUT/liquid-tmp/"$SERIAL"-PBS-IPMI_Summary.txt BMC | sed "s/://g" | sed "/A1-/! s/-//g"
    echo -e "\n==========================================================================\n"
    echo -e "$SERIAL ONBOARD NICS:\n----------------------\n\n"
    grep <OUTPUT/liquid-tmp/"$SERIAL"-PBS-IFCONFIG.txt -E -A5 -i '(Ethernet:|Ethernet 2:)' | xargs -0 | sed 's/^ *//g' | sed "/A1-/! s/-//g"
    echo -e "\n=========================================================================="
  } >>OUTPUT/liquid-tmp/SWQC/MAC-ADDR-List.txt

  # MAC address list

  touch OUTPUT/liquid-tmp/Full-MAC-ADDR-List.txt
  {
    echo -e "==========================================================================\n\n"
    echo -e "MAC ADDRESSES FOR $SERIAL\n--------------------------\n\n"
    grep <OUTPUT/liquid-tmp/"$SERIAL"-PBS-IFCONFIG.txt -E -iB5 "physical Address" | grep -E -iv "media disconnected|connection specific" | sed "/A1-/! s/-//g"
    echo -e "\n"
    grep <OUTPUT/liquid-tmp/"$SERIAL"-PBS-IPMI_Summary.txt -i BMC | sed "s/://g" | sed "/A1-/! s/-//g"
    echo -e "\n"
    echo -e "==========================================================================\n"
  } >>OUTPUT/liquid-tmp/Full-MAC-ADDR-List.txt
  sed <OUTPUT/liquid-tmp/Full-MAC-ADDR-List.txt 's/^ *//g' >OUTPUT/liquid-tmp/SWQC/"$ORDER"-MAC-LIST.txt

  echo "==========================================================================" >>OUTPUT/liquid-tmp/Line-Output.txt

  # Grabbing SEL, SDR, & SENSOR info

  i=0

  until [[ $i -gt 30 ]]; do
    ipmitool -I lanplus -H "$IPMIIP" -U "$IPMIUSER" -P "$IPMIPASSWORD" sdr list >OUTPUT/liquid-tmp/"$SERIAL"-SDR-Data.txt
    sleep 1
    if grep -i ok <OUTPUT/liquid-tmp/"$SERIAL"-SDR-Data.txt; then
      break
    fi
    ((i++))
  done

  ipmitool -I lanplus -H "$IPMIIP" -U "$IPMIUSER" -P "$IPMIPASSWORD" sdr list >OUTPUT/liquid-tmp/"$SERIAL"-SDR-Data.txt
  ipmitool -I lanplus -H "$IPMIIP" -U "$IPMIUSER" -P "$IPMIPASSWORD" sdr list

  i=0

  until [[ $i -gt 5 ]]; do
    ipmitool -I lanplus -H "$IPMIIP" -U "$IPMIUSER" -P "$IPMIPASSWORD" sel list >OUTPUT/liquid-tmp/"$SERIAL"-SEL-Data.txt
    sleep 1
    if ipmitool -I lanplus -H "$IPMIIP" -U "$IPMIUSER" -P "$IPMIPASSWORD" sel list; then
      break
    fi
    ((i++))
  done

  ipmitool -I lanplus -H "$IPMIIP" -U "$IPMIUSER" -P "$IPMIPASSWORD" sel list

  i=0

  until [[ $i -gt 5 ]]; do
    ipmitool -I lanplus -H "$IPMIIP" -U "$IPMIUSER" -P "$IPMIPASSWORD" sensor list >OUTPUT/liquid-tmp/"$SERIAL"-SENSOR-Data.txt
    sleep 1
    if grep -i ok <OUTPUT/liquid-tmp/"$SERIAL"-SENSOR-Data.txt; then
      break
    fi
    ((i++))
  done

  ipmitool -I lanplus -H "$IPMIIP" -U "$IPMIUSER" -P "$IPMIPASSWORD" sensor list

  # Get line count for SDR OK

  i=0

  until [[ $i -gt 5 ]]; do
    ipmitool -I lanplus -H "$IPMIIP" -U "$IPMIUSER" -P "$IPMIPASSWORD" sdr list | grep -ic ok >OUTPUT/liquid-tmp/"$SERIAL"-SDR-OK.txt
    sleep 1
    if [[ -s OUTPUT/liquid-tmp/"$SERIAL"-SDR-OK.txt ]]; then
      break
    fi
    ((i++))
  done

  # Get line count for SENSOR OK

  i=0

  until [[ $i -gt 5 ]]; do
    ipmitool -I lanplus -H "$IPMIIP" -U "$IPMIUSER" -P "$IPMIPASSWORD" sensor list | grep -ic ok >OUTPUT/liquid-tmp/"$SERIAL"-SENSOR-OK.txt
    sleep 1
    if [[ -s OUTPUT/liquid-tmp/"$SERIAL"-SENSOR-OK.txt ]]; then
      break
    fi
    ((i++))
  done

  # Get FRU info

  i=0

  until [[ $i -gt 5 ]]; do
    ipmitool -I lanplus -H "$IPMIIP" -U "$IPMIUSER" -P "$IPMIPASSWORD" fru print 0 | grep -iE "Board Mfg|Board Product|Product Manufacturer|Product Name|Product Serial" >OUTPUT/liquid-tmp/"$SERIAL"-FRU.txt
    sleep 1
    if grep -i product <OUTPUT/liquid-tmp/"$SERIAL"-FRU.txt; then
      break
    fi
    ((i++))
  done

  ipmitool -I lanplus -H "$IPMIIP" -U "$IPMIUSER" -P "$IPMIPASSWORD" fru print 0

  echo "==========================================================================" >>OUTPUT/liquid-tmp/Line-Output.txt

  # Check for missing fans for IX-4224GP2-IXN model

  if [[ "$MODELTYPE" == @(IX-4224GP2-IXN) ]]; then
    grep <OUTPUT/liquid-tmp/"$SERIAL"-SDR-Data.txt -i -v "FAN10" | grep -i 'FAN[17]' >OUTPUT/liquid-tmp/"$SERIAL"-FAN-Data.txt

  elif grep <OUTPUT/liquid-tmp/"$SERIAL"-FAN-Data.txt "no reading"; then
    echo "[CHECK FANS]" >OUTPUT/liquid-tmp/"$SERIAL"-FAN-Check.txt
  fi

  FANERROR=$(cat OUTPUT/liquid-tmp/"$SERIAL"-FAN-Check.txt)

  # Dumping data to consolidate output file

  echo "$SERIAL,$IPMIIP,$IPMIMAC,$PASSVER,$DISK0PF,$TESTDURATION,$IPMIPASSWORD,$PWDV,$MOTHERMAN,$MODELTYPE,$BREAKOUT,$MEMERROR,$CPUTEMP,$NOCPUTEMP,$QLOGIC,$SFTOOB,$SFTDCMS,$FANERROR" | xargs >>OUTPUT/liquid-tmp/CC/"$ORDER"-PBS-OUTPUT.txt

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
    echo -e "BURN-IN RESULTS:\n$PASSVER\n$DISK0PF\n$TESTDURATION\n\n$CERT"
    echo -e "==========================================================================="
    echo -e "SYSTEM INFO:\n$MOTHERMAN\n$MODELTYPE"
    echo -e "==========================================================================="
    echo -e "CONFIGURATIONS:\n$NETSET\n$FANSET"
    echo -e "==========================================================================="
    echo -e "SYSTEM WARNINGS:\n$CPUTEMP\n$MEMERROR\n$NOCPUTEMP\n$BREAKOUT\n$QLOGIC\n$FANERROR\n$MINIEFANERROR\n$SFTOOB\n$SFTDCMS\n$INLET"
  } >>OUTPUT/liquid-tmp/"$ORDER"-REPORT.txt

  echo "$SERIAL $IPMIIP $IPMIUSER $IPMIPASSWORD $IPMIMAC" >>OUTPUT/liquid-tmp/IPMI.txt

done

# Creating CSV file for data transfer

tr -s " " <OUTPUT/liquid-tmp/IPMI.txt >OUTPUT/liquid-tmp/CC/"$ORDER"-IPMI.csv

echo "==========================================================================" >>OUTPUT/liquid-tmp/Line-Output.txt

# Creating GOLD file for diff

LINE=$(head -n 1 OUTPUT/liquid-tmp/Input.txt)

cp OUTPUT/liquid-tmp/"$LINE"-SEL-Data.txt OUTPUT/liquid-tmp/SWQC/GOLD-SEL-Data.txt
cp OUTPUT/liquid-tmp/"$LINE"-SDR-Data.txt OUTPUT/liquid-tmp/SWQC/GOLD-SDR-Data.txt
cp OUTPUT/liquid-tmp/"$LINE"-SENSOR-Data.txt OUTPUT/liquid-tmp/SWQC/GOLD-SENSOR-Data.txt
cp OUTPUT/liquid-tmp/SWQC/"$LINE"-PARTS-List.txt OUTPUT/liquid-tmp/SWQC/GOLD-PARTS-List.txt
cp OUTPUT/liquid-tmp/"$LINE"-SDR-OK.txt OUTPUT/liquid-tmp/SWQC/GOLD-SDR-OK.txt
cp OUTPUT/liquid-tmp/"$LINE"-SENSOR-OK.txt OUTPUT/liquid-tmp/SWQC/GOLD-SENSOR-OK.txt
cp OUTPUT/liquid-tmp/"$LINE"-FRU.txt OUTPUT/liquid-tmp/SWQC/GOLD-FRU.txt

# Diffing each system for errors

FILE=OUTPUT/liquid-tmp/Input.txt
SERIAL=""
exec 3<&0
exec 0<"$FILE"
while read -r LINE; do
  SERIAL=$(echo "$LINE" | cut -d " " -f 1)

  echo "------------------------------------------------------$SERIAL------------------------------------------------------" >>OUTPUT/liquid-tmp/SWQC/"$ORDER"-SEL-DIFF.txt
  diff -y -W 200 --suppress-common-lines OUTPUT/liquid-tmp/SWQC/GOLD-SEL-Data.txt OUTPUT/liquid-tmp/"$SERIAL"-SEL-Data.txt >>OUTPUT/liquid-tmp/SWQC/"$ORDER"-SEL-DIFF.txt

  echo "------------------------------------------------------$SERIAL------------------------------------------------------" >>OUTPUT/liquid-tmp/SWQC/"$ORDER"-SDR-DIFF.txt
  diff -y -W 200 --suppress-common-lines OUTPUT/liquid-tmp/SWQC/GOLD-SDR-Data.txt OUTPUT/liquid-tmp/"$SERIAL"-SDR-Data.txt >>OUTPUT/liquid-tmp/SWQC/"$ORDER"-SDR-DIFF.txt

  echo "------------------------------------------------------$SERIAL------------------------------------------------------" >>OUTPUT/liquid-tmp/SWQC/"$ORDER"-SENSOR-DIFF.txt
  diff -y -W 200 --suppress-common-lines OUTPUT/liquid-tmp/SWQC/GOLD-SENSOR-Data.txt OUTPUT/liquid-tmp/"$SERIAL"-SENSOR-Data.txt >>OUTPUT/liquid-tmp/SWQC/"$ORDER"-SENSOR-DIFF.txt

  echo "------------------------------------------------------$SERIAL------------------------------------------------------" >>OUTPUT/liquid-tmp/SWQC/"$ORDER"-PARTS-DIFF.txt
  diff -y -W 200 --suppress-common-lines OUTPUT/liquid-tmp/SWQC/GOLD-PARTS-List.txt OUTPUT/liquid-tmp/SWQC/"$SERIAL"-PARTS-List.txt >>OUTPUT/liquid-tmp/SWQC/"$ORDER"-PARTS-DIFF.txt

  echo "------------------------------------------------------$SERIAL------------------------------------------------------" >>OUTPUT/liquid-tmp/SWQC/"$ORDER"-SDR-OK-DIFF.txt
  diff -y -W 200 --suppress-common-lines OUTPUT/liquid-tmp/SWQC/GOLD-SDR-OK.txt OUTPUT/liquid-tmp/"$SERIAL"-SDR-OK.txt >>OUTPUT/liquid-tmp/SWQC/"$ORDER"-SDR-OK-DIFF.txt

  echo "------------------------------------------------------$SERIAL------------------------------------------------------" >>OUTPUT/liquid-tmp/SWQC/"$ORDER"-SENSOR-OK-DIFF.txt
  diff -y -W 200 --suppress-common-lines OUTPUT/liquid-tmp/SWQC/GOLD-SENSOR-OK.txt OUTPUT/liquid-tmp/"$SERIAL"-SENSOR-OK.txt >>OUTPUT/liquid-tmp/SWQC/"$ORDER"-SENSOR-OK-DIFF.txt

  echo "------------------------------------------------------$SERIAL------------------------------------------------------" >>OUTPUT/liquid-tmp/SWQC/"$ORDER"-FRU-DIFF.txt
  diff -y -W 200 --suppress-common-lines OUTPUT/liquid-tmp/SWQC/GOLD-FRU.txt OUTPUT/liquid-tmp/"$SERIAL"-FRU.txt >>OUTPUT/liquid-tmp/SWQC/"$ORDER"-FRU-DIFF.txt

done

echo "=====================================END=====================================" >>OUTPUT/liquid-tmp/Line-Output.txt

column <OUTPUT/liquid-tmp/CC/"$ORDER"-PBS-OUTPUT.txt -t -s "," -o " " >OUTPUT/liquid-tmp/CC/"$ORDER"-PBS-OUT.txt
cp OUTPUT/liquid-tmp/SWQC/GOLD-SDR-Data.txt OUTPUT/liquid-tmp/CC
cp OUTPUT/liquid-tmp/SWQC/GOLD-SEL-Data.txt OUTPUT/liquid-tmp/CC
cp OUTPUT/liquid-tmp/SWQC/"$ORDER"-SDR-DIFF.txt OUTPUT/liquid-tmp/CC
cp OUTPUT/liquid-tmp/SWQC/"$ORDER"-SEL-DIFF.txt OUTPUT/liquid-tmp/CC
mv OUTPUT/liquid-tmp/"$SERIAL"-QLOGIC-Check.txt OUTPUT/liquid-tmp/SWQC
mv OUTPUT/liquid-tmp/SWQC/MAC-ADDR-List.txt OUTPUT/liquid-tmp/SWQC/"$ORDER"-MELLANOX-LIST.txt
mv OUTPUT/liquid-tmp/"$ORDER"-REPORT.txt OUTPUT/liquid-tmp/CC
rm OUTPUT/liquid-tmp/CC/"$ORDER"-PBS-OUTPUT.txt
mv OUTPUT/liquid-tmp OUTPUT/"$ORDER"-HRT-Liquid-Immersion-Logs
rm -rf TMP/*.pdf

# Compress output file

tar cfz OUTPUT/"$ORDER"-HRT-Liquid-Immersion-Logs.tar.gz OUTPUT/"$ORDER"-HRT-Liquid-Immersion-Logs

exit
