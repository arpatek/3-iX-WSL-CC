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

rm -rf OUTPUT/ix-tmp

# This is the directories where the data we collect will go

mkdir OUTPUT/ix-tmp
mkdir OUTPUT/ix-tmp/SWQC
mkdir OUTPUT/ix-tmp/CC

# Collecting name of person performing CC

dialog --inputbox "Enter The Name Of The Person Performing CC Here" 10 60 2>OUTPUT/ix-tmp/CC-Person.txt
CCPERSON=$(tr <OUTPUT/ix-tmp/CC-Person.txt '[:lower:]' '[:upper:]')

# Collecting order number for systems

dialog --inputbox "Enter Order Number" 10 60 2>OUTPUT/ix-tmp/Order-Num.txt
ORDER=$(cat OUTPUT/ix-tmp/Order-Num.txt)

# Removing previous files

rm -rf OUTPUT/"$ORDER"-CC-CONF.tar.gz OUTPUT/"$ORDER"-CC-CONF
clear

echo "==========================================================================" >>OUTPUT/ix-tmp/Line-Output.txt

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
} >>OUTPUT/ix-tmp/"$ORDER"-REPORT.txt

# Grabbring serial number from Input.txt

cp ~/3-iX-WSL-CC/SCRIPTS/KEY.txt OUTPUT/ix-tmp/Input.txt

FILE=OUTPUT/ix-tmp/Input.txt
SERIAL=""
exec 3<&0
exec 0<"$FILE"
while read -r LINE; do
  SERIAL=$(echo "$LINE" | cut -d " " -f1)

  touch OUTPUT/ix-tmp/CC/"$ORDER"-PBS-OUTPUT.txt
  touch OUTPUT/ix-tmp/"$SERIAL"-Username.txt
  touch OUTPUT/ix-tmp/IPMI.txt

  echo "==========================================================================" >>OUTPUT/ix-tmp/Line-Output.txt

  # Grabbing Burn-In information from PBS logs

  lynx --dump https://<PBS_ARCHIVE_HOST>/pbsv4/logs/"$SERIAL"/ | tail -1 | cut -d "/" -f7 >OUTPUT/ix-tmp/"$SERIAL"-DIR.txt
  PBSDIRECTORY=$(cat OUTPUT/ix-tmp/"$SERIAL"-DIR.txt)
  curl https://<PBS_ARCHIVE_HOST>/pbsv4/logs/"$SERIAL"/"$PBSDIRECTORY"/ipmi_summary.txt -o OUTPUT/ix-tmp/"$SERIAL"-PBS-IPMI_Summary.txt

  if PBSDIRECTORY=$(cat OUTPUT/ix-tmp/"$SERIAL"-DIR.txt); then
    echo "$PBSDIRECTORY" >OUTPUT/ix-tmp/"$SERIAL"-DIR-Check.txt
    curl https://<PBS_ARCHIVE_HOST>/pbsv4/logs/"$SERIAL"/"$PBSDIRECTORY"/ipmi_summary.txt -o OUTPUT/ix-tmp/"$SERIAL"-PBS-IPMI_Summary.txt

  fi

  # Grabbing Passmark Log

  curl https://<PBS_ARCHIVE_HOST>/pbsv4/logs/"$SERIAL"/"$PBSDIRECTORY"/Passmark_Log.cert.htm -o OUTPUT/ix-tmp/"$SERIAL"-PBS-Passmark_Log.cert.htm
  lynx --dump OUTPUT/ix-tmp/"$SERIAL"-PBS-Passmark_Log.cert.htm >OUTPUT/ix-tmp/"$SERIAL"-Lynx-Cert.txt
  cat OUTPUT/ix-tmp/"$SERIAL"-Lynx-Cert.txt
  lynx --dump OUTPUT/ix-tmp/"$SERIAL"-PBS-Passmark_Log.cert.htm | grep -F "TEST RUN" >OUTPUT/ix-tmp/"$SERIAL"-Test-Run.txt
  tr -s ' ' <OUTPUT/ix-tmp/"$SERIAL"-Test-Run.txt | cut -d ' ' -f 4 | awk '{$1=$1};1' >OUTPUT/ix-tmp/"$SERIAL"-PF.txt
  PASSFAIL=$(cat OUTPUT/ix-tmp/"$SERIAL"-PF.txt)

  if [[ "$PASSFAIL" == "PASSED" ]]; then
    echo "[PASSED]" >OUTPUT/ix-tmp/"$SERIAL"-Passed.txt
  elif [[ "$PASSFAIL" == "FAILED" ]]; then
    echo "[FAILED]" >OUTPUT/ix-tmp/"$SERIAL"-Passed.txt
  fi

  PASSVER=$(cat OUTPUT/ix-tmp/"$SERIAL"-Passed.txt)

  curl https://<PBS_ARCHIVE_HOST>/pbsv4/logs/"$SERIAL"/"$PBSDIRECTORY"/Passmark_Log.htm -o OUTPUT/ix-tmp/"$SERIAL"-PBS-Passmark_Log.htm
  echo -e "https://<PBS_ARCHIVE_HOST>/pbsv4/logs/$SERIAL/$PBSDIRECTORY/Passmark_Log.cert.htm" >OUTPUT/ix-tmp/"$SERIAL"-CERT.txt
  CERT=$(cat OUTPUT/ix-tmp/"$SERIAL"-CERT.txt)

  # CPU presence check

  lynx --dump OUTPUT/ix-tmp/"$SERIAL"-PBS-Passmark_Log.cert.htm | grep -E -i 'CPU 0|CPU 1' >OUTPUT/ix-tmp/"$SERIAL"-CPU-Presence.txt
  if ! [ -s OUTPUT/ix-tmp/"$SERIAL"-CPU-Presence.txt ]; then
    echo "[NO CPU TEMP DETECTED]" >OUTPUT/ix-tmp/"$SERIAL"-NO-CPU-Presence.txt
  fi

  NOCPUTEMP=$(cat OUTPUT/ix-tmp/"$SERIAL"-NO-CPU-Presence.txt)

  # CPU temp check

  lynx --dump OUTPUT/ix-tmp/"$SERIAL"-PBS-Passmark_Log.cert.htm | grep -E -i 'CPU 0|CPU 1' | xargs >OUTPUT/ix-tmp/"$SERIAL"-CPU-Temp.txt
  cut <OUTPUT/ix-tmp/"$SERIAL"-CPU-Temp.txt -d " " -f5 | cut -c 1-2 >OUTPUT/ix-tmp/"$SERIAL"-CPU-Max.txt
  read -r num <OUTPUT/ix-tmp/"$SERIAL"-CPU-Max.txt
  if [[ "$num" -gt 89 ]]; then
    echo "[CPU TEMP ABOVE THRESHOLD]" >OUTPUT/ix-tmp/"$SERIAL"-CPU-Error.txt
  else
    echo "[CPU TEMP OK]"
  fi

  CPUTEMP=$(cat OUTPUT/ix-tmp/"$SERIAL"-CPU-Error.txt)

  # Checking to ensure system ran with test disk

  lynx --dump OUTPUT/ix-tmp/"$SERIAL"-PBS-Passmark_Log.cert.htm | grep ") PASS" | sed -n 2p | awk '{$1=$1};1' >OUTPUT/ix-tmp/"$SERIAL"-Disk00.txt
  DISK00PF=$(cat OUTPUT/ix-tmp/"$SERIAL"-Disk00.txt)

  # Collecting test duration

  lynx --dump OUTPUT/ix-tmp/"$SERIAL"-PBS-Passmark_Log.cert.htm | grep -F "Test Duration" | awk '{$1=$1};1' >OUTPUT/ix-tmp/"$SERIAL"-Test-Duration.txt
  TESTDURATION=$(cat OUTPUT/ix-tmp/"$SERIAL"-Test-Duration.txt)

  # Collecting IPMI IP address

  sed -e "s/\r//g" OUTPUT/ix-tmp/"$SERIAL"-PBS-IPMI_Summary.txt >OUTPUT/ix-tmp/"$SERIAL"-IPMI-Summary.txt

  grep <OUTPUT/ix-tmp/"$SERIAL"-IPMI-Summary.txt -E -i "IPv4 Address" | cut -d ":" -f 2 | awk '{$1=$1};1' >OUTPUT/ix-tmp/"$SERIAL"-IPMI-IPAdddress.txt
  IPMIIP=$(cat OUTPUT/ix-tmp/"$SERIAL"-IPMI-IPAdddress.txt)

  # Collecting IPMI MAC address

  grep <OUTPUT/ix-tmp/"$SERIAL"-IPMI-Summary.txt -E -i "BMC MAC Address" | tr -s ' ' | cut -d " " -f5 >OUTPUT/ix-tmp/"$SERIAL"-BMC-MAC.txt
  IPMIMAC=$(cat OUTPUT/ix-tmp/"$SERIAL"-BMC-MAC.txt)

  # Collecting STD info

  psql -h <DB_HOST> -U <DB_USER> -d <DB_NAME> -c "select c.name, a.model, a.serial, a.rma, a.revision, a.support_number from production_part a, production_system b, production_type c, production_configuration d where a.system_id = b.id and a.type_id = c.id and b.config_name_id = d.id and b.system_serial = '$SERIAL' order by b.system_serial, a.type_id, a.model, a.serial;" >OUTPUT/ix-tmp/"$SERIAL"-STD-Parts.txt
  grep <OUTPUT/ix-tmp/"$SERIAL"-STD-Parts.txt "Unique Password" | cut -d "|" -f 3 | xargs >OUTPUT/ix-tmp/"$SERIAL"-IPMI-Password.txt
  IPMIPASSWORD=$(cat OUTPUT/ix-tmp/"$SERIAL"-IPMI-Password.txt)

  # Checking for break-out cable

  grep <OUTPUT/ix-tmp/"$SERIAL"-STD-Parts.txt -i "Break" >OUTPUT/ix-tmp/"$SERIAL"-Network-Cable.txt
  grep <OUTPUT/ix-tmp/"$SERIAL"-STD-Parts.txt -io "Break" >OUTPUT/ix-tmp/"$SERIAL"-Network-Cable-CP.txt
  cut <OUTPUT/ix-tmp/"$SERIAL"-Network-Cable.txt -d "|" -f2 >OUTPUT/ix-tmp/"$SERIAL"-Network-Cable-Model.txt
  cut <OUTPUT/ix-tmp/"$SERIAL"-Network-Cable.txt -d "|" -f3 >OUTPUT/ix-tmp/"$SERIAL"-Network-Cable-Serial.txt
  NETCABCP=$(cat OUTPUT/ix-tmp/"$SERIAL"-Network-Cable-CP.txt)

  if [[ "$NETCABCP" == "Break" ]]; then
    echo "[BREAK-OUT CABLE]" >OUTPUT/ix-tmp/"$SERIAL"-Break-Out.txt
  fi

  BREAKOUT=$(cat OUTPUT/ix-tmp/"$SERIAL"-Break-Out.txt)

  # Getting motherboard manufacturer info

  lynx --dump OUTPUT/ix-tmp/"$SERIAL"-PBS-Passmark_Log.cert.htm | grep -F "Motherboard manufacturer" | head -n1 | xargs | cut -d " " -f 3 >OUTPUT/ix-tmp/"$SERIAL"-Motherboard-Manufacturer.txt
  MOTHERMAN=$(cat OUTPUT/ix-tmp/"$SERIAL"-Motherboard-Manufacturer.txt)

  # Getting system model type

  lynx --dump OUTPUT/ix-tmp/"$SERIAL"-PBS-Passmark_Log.htm | grep -F "System Model:" | head -n 1 | cut -d " " -f19- >OUTPUT/ix-tmp/"$SERIAL"-System-Model.txt
  # cut <OUTPUT/ix-tmp/"$SERIAL"-System-Model.txt -d " " -f19 >OUTPUT/ix-tmp/"$SERIAL"-Model-Type.txt
  MODELTYPE=$(cat OUTPUT/ix-tmp/"$SERIAL"-System-Model.txt)

  # Checking for wrong memory serial for TrueNAS systems

  curl https://<PBS_ARCHIVE_HOST>/pbsv4/logs/"$SERIAL"/"$PBSDIRECTORY"/DIMM_MemoryChipData.txt -o OUTPUT/ix-tmp/"$SERIAL"-PBS-DIMM_MemoryChipData.txt
  grep <OUTPUT/ix-tmp/"$SERIAL"-PBS-DIMM_MemoryChipData.txt -i "XF" >OUTPUT/ix-tmp/"$SERIAL"-Mem-Check.txt
  MEMSERIALCHECK=$(cat OUTPUT/ix-tmp/"$SERIAL"-Mem-Check.txt)

  # Kingston XF-series NVDIMMs were not qualified for certain TrueNAS models
  if echo "$MEMSERIALCHECK" | grep -F -wqi -e 'XF'; then
    echo "[NVDIMM ERROR]" >OUTPUT/ix-tmp/"$SERIAL"-Mem-Error.txt
  else
    echo "[CORRECT NVDIMM]"
  fi

  MEMERROR=$(cat OUTPUT/ix-tmp/"$SERIAL"-Mem-Error.txt)

  # Check for presence of QLOGIC fibre card

  psql -h <DB_HOST> -U <DB_USER> -d <DB_NAME> -c "select c.name, a.model, a.serial, a.rma, a.revision, a.support_number from production_part a, production_system b, production_type c, production_configuration d where a.system_id = b.id and a.type_id = c.id and b.config_name_id = d.id and b.system_serial = '$SERIAL' order by b.system_serial, a.type_id, a.model, a.serial;" >OUTPUT/ix-tmp/"$SERIAL"-STD-Parts.txt
  grep <OUTPUT/ix-tmp/"$SERIAL"-STD-Parts.txt -i "QLE" | cut -d "|" -f 2 | grep -i -o -P '.{0,0}qle.{0,0}' >OUTPUT/ix-tmp/"$SERIAL"-QLE-Output.txt

  psql -h <DB_HOST> -U <DB_USER> -d <DB_NAME> -c "select c.name, a.model, a.serial, a.rma, a.revision, a.support_number from production_part a, production_system b, production_type c, production_configuration d where a.system_id = b.id and a.type_id = c.id and b.config_name_id = d.id and b.system_serial = '$SERIAL' order by b.system_serial, a.type_id, a.model, a.serial;"

  QLE=$(cat OUTPUT/ix-tmp/"$SERIAL"-QLE-Output.txt)

  if [[ "$QLE" == "QLE" ]]; then

    echo "QLOGIC-CARD-Present-Check-TrueNAS-License" >OUTPUT/ix-tmp/"$SERIAL"-QLOGIC-Check.txt
    echo "[QLOGIC/FC]" >OUTPUT/ix-tmp/"$SERIAL"-QLOGIC-msg.txt
    QLOGIC=$(cat OUTPUT/ix-tmp/"$SERIAL"-QLOGIC-msg.txt)

  fi

  echo "==========================================================================" >>OUTPUT/ix-tmp/Line-Output.txt

  # Creating function for password check

  function PWD-CHECK() {
    i=0

    until [[ $i -gt 40 ]]; do
      ipmitool -I lanplus -H "$IPMIIP" -U "$IPMIUSER" -P "$IPMIPASSWORD" lan print 1 | grep -i "Complete" | tr -s ' ' | cut -d " " -f 6 >OUTPUT/ix-tmp/"$SERIAL"-Passwd-Check.txt
      sleep 1
      if grep -i Complete <OUTPUT/ix-tmp/"$SERIAL"-Passwd-Check.txt; then
        break
      fi
      ((i++))
    done
    ipmitool -I lanplus -H "$IPMIIP" -U "$IPMIUSER" -P "$IPMIPASSWORD" lan print 1
    PWC=$(cat OUTPUT/ix-tmp/"$SERIAL"-Passwd-Check.txt)
  }

  # Creating function for verifying password change

  function PWD-VERIFY() {

    if [[ "$PWC" == *"Complete"* ]]; then
      echo "[PWD VERIFIED]" >OUTPUT/ix-tmp/"$SERIAL"-PWD-Verified.txt
      PWDV=$(cat OUTPUT/ix-tmp/"$SERIAL"-PWD-Verified.txt)

    fi
  }

  echo "==========================================================================" >>OUTPUT/ix-tmp/Line-Output.txt

  # Resetting Supermicro IPMI to default

  if [[ "$MOTHERMAN" == "Supermicro" ]] && [[ -n "$IPMIPASSWORD" ]]; then
    echo "ADMIN" >OUTPUT/ix-tmp/"$SERIAL"-Username.txt
    IPMIUSER=$(cat OUTPUT/ix-tmp/"$SERIAL"-Username.txt)

    lynx --dump OUTPUT/ix-tmp/"$SERIAL"-PBS-Passmark_Log.htm | grep -i "Motherboard Name:" | xargs | cut -d " " -f 3 >OUTPUT/ix-tmp/"$SERIAL"-Supermicro-Model.txt
    SUPER=$(cat OUTPUT/ix-tmp/"$SERIAL"-Supermicro-Model.txt)

  fi

  if [[ "$MOTHERMAN" == "Supermicro" ]] && [[ -n "$IPMIPASSWORD" ]] && [[ "$SUPER" == "A2SDi-H-TF" ]]; then
    ipmitool -H "$IPMIIP" -U ADMIN -P ADMIN user set password 2 "$IPMIPASSWORD"

    sleep 1

    # Check password change completed

    PWD-CHECK
    PWD-VERIFY

  elif [[ "$MOTHERMAN" == "Supermicro" ]] && [[ -n "$IPMIPASSWORD" ]]; then
    ipmitool -I lanplus -H "$IPMIIP" -U ADMIN -P ADMIN raw 0x3c 0x40 # Supermicro OEM: factory resets BMC to default settings

    #yes | pv -SpeL1 -s 45 > /dev/null

    # Check password change completed

    PWD-CHECK
    PWD-VERIFY

  fi

  # Setting network and fan speeds to required settings

  if [[ "$MODELTYPE" == @(TRUENAS-MINI-3.0-X+|TRUENAS-MINI-3.0-XL+|TRUENAS-MINI-R) ]]; then
    ipmitool -H "$IPMIIP" -U ADMIN -P "$IPMIPASSWORD" raw 0x30 0x70 0x0c 1 0 # Supermicro OEM: set BMC NIC to Dedicated mode (vs Shared/Failover)
    echo "<NETWORK: DEDICATED>" >OUTPUT/ix-tmp/"$SERIAL"-Net-Change.txt
    ipmitool -H "$IPMIIP" -U ADMIN -P "$IPMIPASSWORD" raw 0x30 0x45 0x01 0x00 # Supermicro OEM fan profile: Standard
    echo "<FAN: STANDARD>" >OUTPUT/ix-tmp/"$SERIAL"-Fan-Set.txt

  elif [[ "$MODELTYPE" == @(TRUENAS-R10|TRUENAS-R40) ]]; then
    ipmitool -H "$IPMIIP" -U ADMIN -P "$IPMIPASSWORD" raw 0x30 0x70 0x0c 1 0 # Supermicro OEM: set BMC NIC to Dedicated mode
    echo "<NETWORK: DEDICATED>" >OUTPUT/ix-tmp/"$SERIAL"-Net-Change.txt
    ipmitool -H "$IPMIIP" -U ADMIN -P "$IPMIPASSWORD" raw 0x30 0x45 0x01 0x00 # Supermicro OEM fan profile: Standard
    echo "<FAN: STANDARD>" >OUTPUT/ix-tmp/"$SERIAL"-Fan-Set.txt

  elif [[ "$MODELTYPE" == @(TRUENAS-M30-S|TRUENAS-M30-HA|TRUENAS-M40-S|TRUENAS-M40-HA|TRUENAS-M50|TRUENAS-M50-S|TRUENAS-M50-HA|TRUENAS-M60-S|TRUENAS-M60-HA) ]]; then
    ipmitool -H "$IPMIIP" -U ADMIN -P "$IPMIPASSWORD" raw 0x30 0x70 0x0c 1 0 # Set network to Dedicated
    echo "<NETWORK: DEDICATED>" >OUTPUT/ix-tmp/"$SERIAL"-Net-Change.txt
    ipmitool -H "$IPMIIP" -U ADMIN -P "$IPMIPASSWORD" raw 0x30 0x45 0x01 0x00 # Set fan to Standard
    echo "<FAN: STANDARD>" >OUTPUT/ix-tmp/"$SERIAL"-Fan-Set.txt

  elif [[ "$MODELTYPE" == @(TRUENAS-R20B) ]]; then
    ipmitool -H "$IPMIIP" -U ADMIN -P "$IPMIPASSWORD" raw 0x30 0x70 0x0c 1 0 # Set network to Dedicated
    echo "<NETWORK: DEDICATED>" >OUTPUT/ix-tmp/"$SERIAL"-Net-Change.txt
    ipmitool -H "$IPMIIP" -U ADMIN -P "$IPMIPASSWORD" raw 0x30 0x45 0x01 0x04 # Supermicro OEM fan profile: Heavy IO
    echo "<FAN: HEAVY IO>" >OUTPUT/ix-tmp/"$SERIAL"-Fan-Set.txt

  elif [[ "$MODELTYPE" == @(TRUENAS-R50B) ]]; then
    ipmitool -H "$IPMIIP" -U ADMIN -P "$IPMIPASSWORD" raw 0x30 0x70 0x0c 1 0 # Set network to Dedicated
    echo "<NETWORK: DEDICATED>" >OUTPUT/ix-tmp/"$SERIAL"-Net-Change.txt
    ipmitool -H "$IPMIIP" -U ADMIN -P "$IPMIPASSWORD" raw 0x30 0x45 0x01 0x01 # Supermicro OEM fan profile: Full Speed
    echo "<FAN: FULL SPEED>" >OUTPUT/ix-tmp/"$SERIAL"-Fan-Set.txt

  elif [[ "$MODELTYPE" == @(TRUENAS-R50BM) ]]; then
    ipmitool -H "$IPMIIP" -U ADMIN -P "$IPMIPASSWORD" raw 0x30 0x70 0x0c 1 0 # Set network to Dedicated
    echo "<NETWORK: DEDICATED>" >OUTPUT/ix-tmp/"$SERIAL"-Net-Change.txt
    ipmitool -H "$IPMIIP" -U ADMIN -P "$IPMIPASSWORD" raw 0x30 0x45 0x01 0x02 # Supermicro OEM fan profile: Optimal
    echo "<FAN: OPTIMAL>" >OUTPUT/ix-tmp/"$SERIAL"-Fan-Set.txt

  fi

  # Setting fan threshold for TrueNAS MINI X+ & XL+

  if [[ "$MODELTYPE" == @(TRUENAS-MINI-3.0-X+) ]]; then
    # Threshold args: lower-non-recoverable, lower-critical, lower-non-critical (RPM)
    # MINI X+ uses a single slower fan (FANA) — lower thresholds prevent false alarms
    ipmitool -I lanplus -U ADMIN -P "$IPMIPASSWORD" -H "$IPMIIP" sensor thresh FANA lower 200 300 500
    echo "<FAN: THRESHOLD SET 200 300 500 (FANA)>" >>OUTPUT/ix-tmp/"$SERIAL"-Fan-Set.txt

  elif [[ "$MODELTYPE" == @(TRUENAS-MINI-3.0-XL+) ]]; then
    # XL+ has three slower fans (FANA, FAN1, FAN2) vs standard models
    ipmitool -I lanplus -U ADMIN -P "$IPMIPASSWORD" -H "$IPMIIP" sensor thresh FANA lower 200 300 500
    ipmitool -I lanplus -U ADMIN -P "$IPMIPASSWORD" -H "$IPMIIP" sensor thresh FAN1 lower 200 300 500
    ipmitool -I lanplus -U ADMIN -P "$IPMIPASSWORD" -H "$IPMIIP" sensor thresh FAN2 lower 200 300 500
    echo "<FAN: THRESHOLD SET 200 300 500 (FANA,FAN1,FAN2)>" >>OUTPUT/ix-tmp/"$SERIAL"-Fan-Set.txt

  fi

  # Setting fan threshold for TrueNAS-R20B

  if [[ "$MODELTYPE" == @(TRUENAS-R20B) ]]; then
    # R20B rear fans (FAN2-4) run slower than front fans — lower thresholds prevent false alarms
    ipmitool -I lanplus -U ADMIN -P "$IPMIPASSWORD" -H "$IPMIIP" sensor thresh FAN2 lower 100 200 200
    ipmitool -I lanplus -U ADMIN -P "$IPMIPASSWORD" -H "$IPMIIP" sensor thresh FAN3 lower 100 200 200
    ipmitool -I lanplus -U ADMIN -P "$IPMIPASSWORD" -H "$IPMIIP" sensor thresh FAN4 lower 100 200 200
    echo "<FAN: THRESHOLD SET 100 200 200 (FAN2,FAN3,FAN4)>" >>OUTPUT/ix-tmp/"$SERIAL"-Fan-Set.txt

  fi

  NETSET=$(cat OUTPUT/ix-tmp/"$SERIAL"-Net-Change.txt)
  FANSET=$(cat OUTPUT/ix-tmp/"$SERIAL"-Fan-Set.txt)

  echo "==========================================================================" >>OUTPUT/ix-tmp/Line-Output.txt

  # Resetting ASUSTeK IPMI to default

  if [[ "$MOTHERMAN" == "ASUSTeK" ]] && [[ -n "$IPMIPASSWORD" ]]; then
    echo "admin" >OUTPUT/ix-tmp/"$SERIAL"-Username.txt
    IPMIUSER=$(cat OUTPUT/ix-tmp/"$SERIAL"-Username.txt)

    ipmitool -I lanplus -H "$IPMIIP" -U admin -P admin user set password 2 "$IPMIPASSWORD" || ipmitool -I lanplus -H "$IPMIIP" -U admin -P administrator user set password 2 "$IPMIPASSWORD"
    sleep 1

    # Check password change completed

    PWD-CHECK
    PWD-VERIFY

  fi

  echo "==========================================================================" >>OUTPUT/ix-tmp/Line-Output.txt


  # Resetting Giga Computing IPMI to default

  if [[ "$MOTHERMAN" == "Giga" ]] && [[ -n "$IPMIPASSWORD" ]]; then
    echo "admin" >OUTPUT/ix-tmp/"$SERIAL"-Username.txt
    IPMIUSER=$(cat OUTPUT/ix-tmp/"$SERIAL"-Username.txt)

    ipmitool -I lanplus -H "$IPMIIP" -U admin -P admin user set password 2 "$IPMIPASSWORD" || ipmitool -I lanplus -H "$IPMIIP" -U admin -P administrator user set password 2 "$IPMIPASSWORD"
    sleep 1

    # Check password change completed

    PWD-CHECK
    PWD-VERIFY

  fi

  echo "==========================================================================" >>OUTPUT/ix-tmp/Line-Output.txt

  # Resetting ASRockRack IPMI to default

  if [[ "$MOTHERMAN" == "ASRockRack" ]] && [[ -n "$IPMIPASSWORD" ]]; then
    echo "admin" >OUTPUT/ix-tmp/"$SERIAL"-Username.txt
    IPMIUSER=$(cat OUTPUT/ix-tmp/"$SERIAL"-Username.txt)

    ipmitool -I lanplus -H "$IPMIIP" -U admin -P admin user set password 2 "$IPMIPASSWORD" || ipmitool -I lanplus -H "$IPMIIP" -U ADMIN -P ADMIN user set password 2 "$IPMIPASSWORD"
    sleep 1

    # Check password change completed

    PWD-CHECK
    PWD-VERIFY

  fi

  echo "==========================================================================" >>OUTPUT/ix-tmp/Line-Output.txt

  # Resetting GIGABYTE IPMI to default

  if [[ "$MOTHERMAN" == "GIGABYTE" ]] && [[ -n "$IPMIPASSWORD" ]]; then
    echo "admin" >OUTPUT/ix-tmp/"$SERIAL"-Username.txt
    IPMIUSER=$(cat OUTPUT/ix-tmp/"$SERIAL"-Username.txt)

    ipmitool -I lanplus -H "$IPMIIP" -U admin -P password user set password 2 "$IPMIPASSWORD" || ipmitool -I lanplus -H "$IPMIIP" -U admin -P administrator user set password 2 "$IPMIPASSWORD"
    sleep 1

    # Check password change completed

    PWD-CHECK
    PWD-VERIFY

  fi

  echo "==========================================================================" >>OUTPUT/ix-tmp/Line-Output.txt

  curl https://<PBS_ARCHIVE_HOST>/pbsv4/logs/"$SERIAL"/"$PBSDIRECTORY"/ipconfig.txt -o OUTPUT/ix-tmp/"$SERIAL"-PBS-Interface_Configuration.txt

  curl https://<PBS_ARCHIVE_HOST>/pbsv4/logs/"$SERIAL"/"$PBSDIRECTORY"/ipmi_powersupply_status.txt -o OUTPUT/ix-tmp/"$SERIAL"-PBS-IPMI_Powersupply_Status.txt

  curl https://<PBS_ARCHIVE_HOST>/pbsv4/logs/"$SERIAL"/"$PBSDIRECTORY"/ipmi_sel_list.txt -o OUTPUT/ix-tmp/"$SERIAL"-PBS-IPMI_SEL_List.txt

  curl https://<PBS_ARCHIVE_HOST>/pbsv4/logs/"$SERIAL"/"$PBSDIRECTORY"/ipmi_temperature.txt -o OUTPUT/ix-tmp/"$SERIAL"-PBS-IPMI_Temperature.txt

  curl https://<PBS_ARCHIVE_HOST>/pbsv4/logs/"$SERIAL"/"$PBSDIRECTORY"/WMIC_Bios.txt -o OUTPUT/ix-tmp/"$SERIAL"-PBS-WMIC_BIOS.txt

  curl https://<PBS_ARCHIVE_HOST>/pbsv4/logs/"$SERIAL"/"$PBSDIRECTORY"/wmic_full_information.txt -o OUTPUT/ix-tmp/"$SERIAL"-PBS-WMIC_Full_Information.txt

  curl https://<PBS_ARCHIVE_HOST>/pbsv4/logs/"$SERIAL"/"$PBSDIRECTORY"/DiskDrive_AllInformation.txt -o OUTPUT/ix-tmp/"$SERIAL"-PBS-DiskDrive_AllInformation.txt

  curl https://<PBS_ARCHIVE_HOST>/pbsv4/logs/"$SERIAL"/"$PBSDIRECTORY"/DiskDrive_SerialNumbers.txt -o OUTPUT/ix-tmp/"$SERIAL"-PBS-DiskDrive_SerialNumbers.txt

  curl https://<PBS_ARCHIVE_HOST>/pbsv4/logs/"$SERIAL"/"$PBSDIRECTORY"/Enclosures.txt -o OUTPUT/ix-tmp/"$SERIAL"-PBS-Enclosures.txt

  curl https://<PBS_ARCHIVE_HOST>/pbsv4/logs/"$SERIAL"/"$PBSDIRECTORY"/IP_Address.txt -o OUTPUT/ix-tmp/"$SERIAL"-PBS-IP_Address.txt

  curl https://<PBS_ARCHIVE_HOST>/pbsv4/logs/"$SERIAL"/"$PBSDIRECTORY"/passmark_image.png -o OUTPUT/ix-tmp/"$SERIAL"-PBS-Passmark_Image.png

  echo "==========================================================================" >>OUTPUT/ix-tmp/Line-Output.txt

  # Checking if OOB/DCMS license is needed (Must add work order to TMP folder)

  # Work order PDFs are manually placed in TMP/ before running; scanned here for license SKUs
  pdfgrep 'SFT-OOB-LIC' TMP/*.pdf | xargs | cut -d " " -f 1 >OUTPUT/ix-tmp/"$SERIAL"-OOB-Check.txt

  if grep -q "SFT-OOB-LIC" OUTPUT/ix-tmp/"$SERIAL"-OOB-Check.txt; then
    echo "[OOB LICENSE REQUIRED]" >OUTPUT/ix-tmp/"$SERIAL"-OOB-Alert.txt
  fi

  pdfgrep 'SFT-DCMS-SINGLE' TMP/*.pdf | xargs | cut -d " " -f 1 >OUTPUT/ix-tmp/"$SERIAL"-DCMS-Check.txt

  if grep -q "SFT-DCMS-SINGLE" OUTPUT/ix-tmp/"$SERIAL"-DCMS-Check.txt; then
    echo "[DCMS LICENSE REQUIRED]" >OUTPUT/ix-tmp/"$SERIAL"-DCMS-Alert.txt
  fi

  SFTOOB=$(cat OUTPUT/ix-tmp/OOB-Alert.txt)
  SFTDCMS=$(cat OUTPUT/ix-tmp/DCMS-Alert.txt)

  # Grabbing parts lists for DIFF between systems

  touch OUTPUT/ix-tmp/SWQC/"$SERIAL"-PARTS-List.txt
  grep <OUTPUT/ix-tmp/"$SERIAL"-PBS-WMIC_Full_Information.txt -E -i "product=" >OUTPUT/ix-tmp/"$SERIAL"-Motherboard.txt
  {
    echo -e "==========================================================================\n\n"
    echo -e "[MOTHERBOARD]\n-------------\n\n"
    cut <OUTPUT/ix-tmp/"$SERIAL"-Motherboard.txt -d "=" -f 2-
    echo -e "\n"
    echo -e "[CPU]\n-----\n\n"
    lynx --dump OUTPUT/ix-tmp/"$SERIAL"-PBS-Passmark_Log.cert.htm | grep -F "CPU type" | xargs
    echo -e "\n\n"
    echo -e "[MEMORY]\n--------\n\n"
    sed -n -e '/Physical Memory Information:/,/CPU Information:/ p' OUTPUT/ix-tmp/"$SERIAL"-PBS-WMIC_Full_Information.txt | head -n -1
    echo -e "[DRIVES]\n--------\n\n"
    iconv -f UTF-16LE -t UTF-8 OUTPUT/ix-tmp/"$SERIAL"-PBS-DiskDrive_SerialNumbers.txt # PBS disk serial logs from Windows (WMIC) are saved as UTF-16LE
    echo -e "=========================================================================="
  } >>OUTPUT/ix-tmp/SWQC/"$SERIAL"-PARTS-List.txt

  # Grabbing Mellanox MAC address for SWQC/Asset List

  touch OUTPUT/ix-tmp/SWQC/"$SERIAL"-MAC-ADDR-List.txt
  {
    echo -e "==========================================================================\n"
    echo -e "$SERIAL MELLANOX CHECK:\n------------------------\n\n"
    grep <OUTPUT/ix-tmp/"$SERIAL"-PBS-Interface_Configuration.txt -i -A3 -B1 mellanox | xargs -0 | sed 's/^ *//g' | sed "/A1-/! s/-//g" # strips hyphens from MACs but preserves iX serial format (A1-XXXXX)
    echo -e "\n==========================================================================\n"
    echo -e "$SERIAL IPMI:\n--------------\n\n"
    grep <OUTPUT/ix-tmp/"$SERIAL"-PBS-IPMI_Summary.txt BMC | sed "s/://g" | sed "/A1-/! s/-//g"
    echo -e "\n==========================================================================\n"
    echo -e "$SERIAL ONBOARD NICS:\n----------------------\n\n"
    grep <OUTPUT/ix-tmp/"$SERIAL"-PBS-Interface_Configuration.txt -E -A5 -i '(Ethernet:|Ethernet 2:)' | xargs -0 | sed 's/^ *//g' | sed "/A1-/! s/-//g"
    echo -e "\n=========================================================================="
  } >>OUTPUT/ix-tmp/SWQC/"$SERIAL"-MAC-ADDR-List.txt

  # MAC address list

  touch OUTPUT/ix-tmp/Full-MAC-Address-List.txt
  {
    echo -e "==========================================================================\n\n"
    echo -e "MAC ADDRESSES FOR $SERIAL\n--------------------------\n\n"
    grep <OUTPUT/ix-tmp/"$SERIAL"-PBS-Interface_Configuration.txt -E -iB5 "physical Address" | grep -E -iv "media disconnected|connection specific" | sed "/A1-/! s/-//g"
    echo -e "\n"
    grep <OUTPUT/ix-tmp/"$SERIAL"-PBS-IPMI_Summary.txt -i BMC | sed "s/://g" | sed "/A1-/! s/-//g"
    echo -e "\n"
    echo -e "==========================================================================\n"
  } >>OUTPUT/ix-tmp/Full-MAC-Address-List.txt
  sed <OUTPUT/ix-tmp/Full-MAC-Address-List.txt 's/^ *//g' >OUTPUT/ix-tmp/SWQC/"$ORDER"-MAC-LIST.txt

  echo "==========================================================================" >>OUTPUT/ix-tmp/Line-Output.txt

  # Grabbing SEL, SDR, & SENSOR info

  i=0

  # Up to 40 retries: BMC can take ~30-40s to respond after a factory reset
  until [[ $i -gt 40 ]]; do
    ipmitool -I lanplus -H "$IPMIIP" -U "$IPMIUSER" -P "$IPMIPASSWORD" sdr list >OUTPUT/ix-tmp/"$SERIAL"-SDR-Data.txt
    sleep 1
    if grep -i ok <OUTPUT/ix-tmp/"$SERIAL"-SDR-Data.txt; then
      break
    fi
    ((i++))
  done

  ipmitool -I lanplus -H "$IPMIIP" -U "$IPMIUSER" -P "$IPMIPASSWORD" sdr list >OUTPUT/ix-tmp/"$SERIAL"-SDR-Data.txt
  ipmitool -I lanplus -H "$IPMIIP" -U "$IPMIUSER" -P "$IPMIPASSWORD" sdr list

  i=0

  until [[ $i -gt 5 ]]; do
    ipmitool -I lanplus -H "$IPMIIP" -U "$IPMIUSER" -P "$IPMIPASSWORD" sel list >OUTPUT/ix-tmp/"$SERIAL"-SEL-Data.txt
    sleep 1
    if ipmitool -I lanplus -H "$IPMIIP" -U "$IPMIUSER" -P "$IPMIPASSWORD" sel list; then
      break
    fi
    ((i++))
  done

  ipmitool -I lanplus -H "$IPMIIP" -U "$IPMIUSER" -P "$IPMIPASSWORD" sel list

  i=0

  until [[ $i -gt 5 ]]; do
    ipmitool -I lanplus -H "$IPMIIP" -U "$IPMIUSER" -P "$IPMIPASSWORD" sensor list >OUTPUT/ix-tmp/"$SERIAL"-SENSOR-Data.txt
    sleep 1
    if grep -i ok <OUTPUT/ix-tmp/"$SERIAL"-SENSOR-Data.txt; then
      break
    fi
    ((i++))
  done

  ipmitool -I lanplus -H "$IPMIIP" -U "$IPMIUSER" -P "$IPMIPASSWORD" sensor list

  # Get LINE count for SDR OK

  i=0

  until [[ $i -gt 5 ]]; do
    ipmitool -I lanplus -H "$IPMIIP" -U "$IPMIUSER" -P "$IPMIPASSWORD" sdr list | grep -ic ok >OUTPUT/ix-tmp/"$SERIAL"-SDR-OK.txt
    sleep 1
    if [[ -s OUTPUT/ix-tmp/"$SERIAL"-SDR-OK.txt ]]; then
      break
    fi
    ((i++))
  done

  # Get FRU info

  i=0

  until [[ $i -gt 5 ]]; do
    ipmitool -I lanplus -H "$IPMIIP" -U "$IPMIUSER" -P "$IPMIPASSWORD" fru print 0 | grep -iE "Board Mfg|Board Product|Product Manufacturer|Product Name|Product Serial" >OUTPUT/ix-tmp/"$SERIAL"-FRU.txt
    sleep 1
    if grep -i product <OUTPUT/ix-tmp/"$SERIAL"-FRU.txt; then
      break
    fi
    ((i++))
  done

  ipmitool -I lanplus -H "$IPMIIP" -U "$IPMIUSER" -P "$IPMIPASSWORD" fru print 0

  echo "==========================================================================" >>OUTPUT/ix-tmp/Line-Output.txt

  # Checking SEL for ECC & Non-critical errors

  echo "------------------------------------------------------$SERIAL------------------------------------------------------" >>OUTPUT/ix-tmp/SWQC/"$ORDER"-SEL-ERRORS.txt
  grep -Ei 'ECC|Non-critical' OUTPUT/ix-tmp/"$SERIAL"-SEL-Data.txt >>OUTPUT/ix-tmp/SWQC/"$ORDER"-SEL-ERRORS.txt

  # Check for missing fans for IX-4224GP2-IXN model

  if [[ "$MODELTYPE" == @(IX-4224GP2-IXN) ]]; then
    grep <OUTPUT/ix-tmp/"$SERIAL"-SDR-Data.txt -i -v "FAN10" | grep -i 'FAN[17]' >OUTPUT/ix-tmp/"$SERIAL"-FAN-Data.txt

  elif grep <OUTPUT/ix-tmp/"$SERIAL"-FAN-Data.txt "no reading"; then
    echo "[CHECK FANS]" >OUTPUT/ix-tmp/"$SERIAL"-FAN-Check.txt
  fi

  FANERROR=$(cat OUTPUT/ix-tmp/"$SERIAL"-FAN-Check.txt)

  # Dumping data to consolidate output file

  echo "$SERIAL,$IPMIIP,$IPMIMAC,$PASSVER,$DISK00PF,$TESTDURATION,$IPMIPASSWORD,$PWDV,$MOTHERMAN,$MODELTYPE,$BREAKOUT,$MEMERROR,$CPUTEMP,$NOCPUTEMP,$QLOGIC,$SFTOOB,$SFTDCMS,$FANERROR" | xargs >>OUTPUT/ix-tmp/CC/"$ORDER"-PBS-OUTPUT.txt

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
  } >>OUTPUT/ix-tmp/"$ORDER"-REPORT.txt

  echo "$SERIAL $IPMIIP $IPMIUSER $IPMIPASSWORD $IPMIMAC" >>OUTPUT/ix-tmp/IPMI.txt

done

# Creating CSV file for data transfer

tr -s " " <OUTPUT/ix-tmp/IPMI.txt >OUTPUT/ix-tmp/CC/"$ORDER"-IPMI.csv
cat OUTPUT/ix-tmp/CC/"$ORDER"-IPMI.csv

echo "==========================================================================" >>OUTPUT/ix-tmp/Line-Output.txt

# Creating GOLD file for diff
# First serial in KEY.txt becomes the baseline; all others are diffed against it.
# For production batches of identical hardware, any difference flags a config error.

LINE=$(head -n 1 OUTPUT/ix-tmp/Input.txt)

cp OUTPUT/ix-tmp/"$LINE"-SEL-Data.txt OUTPUT/ix-tmp/SWQC/GOLD-SEL-Data.txt
cp OUTPUT/ix-tmp/"$LINE"-SDR-Data.txt OUTPUT/ix-tmp/SWQC/GOLD-SDR-Data.txt
cp OUTPUT/ix-tmp/"$LINE"-SENSOR-Data.txt OUTPUT/ix-tmp/SWQC/GOLD-SENSOR-Data.txt
cp OUTPUT/ix-tmp/SWQC/"$LINE"-PARTS-List.txt OUTPUT/ix-tmp/SWQC/GOLD-PARTS-List.txt
cp OUTPUT/ix-tmp/"$LINE"-SDR-OK.txt OUTPUT/ix-tmp/SWQC/GOLD-SDR-OK.txt
cp OUTPUT/ix-tmp/"$LINE"-SENSOR-OK.txt OUTPUT/ix-tmp/SWQC/GOLD-SENSOR-OK.txt
cp OUTPUT/ix-tmp/"$LINE"-FRU.txt OUTPUT/ix-tmp/SWQC/GOLD-FRU.txt
cp OUTPUT/ix-tmp/"$LINE"-STD-Parts.txt OUTPUT/ix-tmp/SWQC/GOLD-STD-Parts.txt

# Diffing each system for errors

FILE=OUTPUT/ix-tmp/Input.txt
SERIAL=""
exec 3<&0
exec 0<"$FILE"
while read -r LINE; do
  SERIAL=$(echo "$LINE" | cut -d " " -f 1)

  echo "------------------------------------------------------$SERIAL------------------------------------------------------" >>OUTPUT/ix-tmp/SWQC/"$ORDER"-SEL-DIFF.txt
  diff -y -W 200 --suppress-common-lines OUTPUT/ix-tmp/SWQC/GOLD-SEL-Data.txt OUTPUT/ix-tmp/"$SERIAL"-SEL-Data.txt >>OUTPUT/ix-tmp/SWQC/"$ORDER"-SEL-DIFF.txt

  echo "------------------------------------------------------$SERIAL------------------------------------------------------" >>OUTPUT/ix-tmp/SWQC/"$ORDER"-SDR-DIFF.txt
  diff -y -W 200 --suppress-common-lines OUTPUT/ix-tmp/SWQC/GOLD-SDR-Data.txt OUTPUT/ix-tmp/"$SERIAL"-SDR-Data.txt >>OUTPUT/ix-tmp/SWQC/"$ORDER"-SDR-DIFF.txt

  echo "------------------------------------------------------$SERIAL------------------------------------------------------" >>OUTPUT/ix-tmp/SWQC/"$ORDER"-SENSOR-DIFF.txt
  diff -y -W 200 --suppress-common-lines OUTPUT/ix-tmp/SWQC/GOLD-SENSOR-Data.txt OUTPUT/ix-tmp/"$SERIAL"-SENSOR-Data.txt >>OUTPUT/ix-tmp/SWQC/"$ORDER"-SENSOR-DIFF.txt

  echo "------------------------------------------------------$SERIAL------------------------------------------------------" >>OUTPUT/ix-tmp/SWQC/"$ORDER"-PARTS-DIFF.txt
  diff -y -W 200 --suppress-common-lines OUTPUT/ix-tmp/SWQC/GOLD-PARTS-List.txt OUTPUT/ix-tmp/SWQC/"$SERIAL"-PARTS-List.txt >>OUTPUT/ix-tmp/SWQC/"$ORDER"-PARTS-DIFF.txt

  echo "------------------------------------------------------$SERIAL------------------------------------------------------" >>OUTPUT/ix-tmp/SWQC/"$ORDER"-SDR-OK-DIFF.txt
  diff -y -W 200 --suppress-common-lines OUTPUT/ix-tmp/SWQC/GOLD-SDR-OK.txt OUTPUT/ix-tmp/"$SERIAL"-SDR-OK.txt >>OUTPUT/ix-tmp/SWQC/"$ORDER"-SDR-OK-DIFF.txt

  echo "------------------------------------------------------$SERIAL------------------------------------------------------" >>OUTPUT/ix-tmp/SWQC/"$ORDER"-SENSOR-OK-DIFF.txt
  diff -y -W 200 --suppress-common-lines OUTPUT/ix-tmp/SWQC/GOLD-SENSOR-OK.txt OUTPUT/ix-tmp/"$SERIAL"-SENSOR-OK.txt >>OUTPUT/ix-tmp/SWQC/"$ORDER"-SENSOR-OK-DIFF.txt

  echo "------------------------------------------------------$SERIAL------------------------------------------------------" >>OUTPUT/ix-tmp/SWQC/"$ORDER"-FRU-DIFF.txt
  diff -y -W 200 --suppress-common-lines OUTPUT/ix-tmp/SWQC/GOLD-FRU.txt OUTPUT/ix-tmp/"$SERIAL"-FRU.txt >>OUTPUT/ix-tmp/SWQC/"$ORDER"-FRU-DIFF.txt

  echo "------------------------------------------------------$SERIAL------------------------------------------------------" >>OUTPUT/ix-tmp/SWQC/"$ORDER"-STD-Parts-DIFF.txt
  diff -y -W 200 --suppress-common-lines OUTPUT/ix-tmp/SWQC/GOLD-STD-Parts.txt OUTPUT/ix-tmp/"$SERIAL"-STD-Parts.txt >>OUTPUT/ix-tmp/SWQC/"$ORDER"-STD-Parts-DIFF.txt

done

echo "=====================================END=====================================" >>OUTPUT/ix-tmp/Line-Output.txt

column <OUTPUT/ix-tmp/CC/"$ORDER"-PBS-OUTPUT.txt -t -s "," -o " " >OUTPUT/ix-tmp/CC/"$ORDER"-PBS-OUT.txt
cp OUTPUT/ix-tmp/SWQC/GOLD-SDR-Data.txt OUTPUT/ix-tmp/CC
cp OUTPUT/ix-tmp/SWQC/GOLD-SEL-Data.txt OUTPUT/ix-tmp/CC
cp OUTPUT/ix-tmp/SWQC/"$ORDER"-SDR-DIFF.txt OUTPUT/ix-tmp/CC
cp OUTPUT/ix-tmp/SWQC/"$ORDER"-SEL-DIFF.txt OUTPUT/ix-tmp/CC
mv OUTPUT/ix-tmp/"$SERIAL"-QLOGIC-Check.txt OUTPUT/ix-tmp/SWQC
mv OUTPUT/ix-tmp/SWQC/"$SERIAL"-MAC-ADDR-List.txt OUTPUT/ix-tmp/SWQC/"$ORDER"-MELLANOX-LIST.txt
mv OUTPUT/ix-tmp/"$ORDER"-REPORT.txt OUTPUT/ix-tmp/CC
rm OUTPUT/ix-tmp/CC/"$ORDER"-PBS-OUTPUT.txt
mv OUTPUT/ix-tmp OUTPUT/"$ORDER"-CC-CONF
rm -rf TMP/*.pdf

# Compress output file

tar cfz OUTPUT/"$ORDER-CC-CONF.tar.gz" OUTPUT/"$ORDER"-CC-CONF

exit
