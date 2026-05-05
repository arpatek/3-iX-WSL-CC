#!/bin/bash
# Title: CC-Config-ARM.sh
# Description: Get PBS Information & Configure System
# Author: Juan Garcia
# Updated: 05:05:2022
# Version: 3.0
#########################################################################################################
# DEPENDENCIES:
#
# dialog needs to be installed: sudo apt-get install dialog -y
# psql needs to be installed: sudo apt-get install postgresql-client-common -y
# lynx needs to be installed: sudo apt-get install lynx -y
# curl needs to be installed: sudo apt-get install curl -y
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

rm -rf OUTPUT/ix-tmp/

# Making temp file for SWQC check *.txt
# This is the directory where the data we collect will go

mkdir OUTPUT/ix-tmp

# Collecting name of person performing CC

dialog --inputbox "Enter The Name Of The Person Performing CC Here" 10 60 2>OUTPUT/ix-tmp/cc-person.txt
CCPERSON=$(cat OUTPUT/ix-tmp/cc-person.txt | tr '[:lower:]' '[:upper:]')

# Collecting order number for systems

dialog --inputbox "Enter Order Number" 10 60 2>OUTPUT/ix-tmp/ordertemp.txt
ORDER=$(cat OUTPUT/ix-tmp/ordertemp.txt)

# Removing previous files

rm -rf "$ORDER"-CC-CONF.tar.gz "$ORDER"-CC-CONF/
touch OUTPUT/ix-tmp/"$ORDER"-PBS-output.txt

{
  echo "==========================================================================";

  echo "ORDER INFORMATION:";
  echo "Order Number: $ORDER";

  echo "==========================================================================" 
}>>OUTPUT/ix-tmp/swqc-output.txt

# Header for CC report

{
  echo "------------------------------------------";
  echo -e "IXSYSTEMS INC. CLIENT CONFIGURATION REPORT\n";
  echo "------------------------------------------";
  echo -e "\n";
  date;
  echo -e "\n------------------------------------------\nCC PERSON:\n$CCPERSON\n\n------------------------------------------\n------------------------------------------\nORDER NUMBER:\n$ORDER\n\n------------------------------------------\n\n\n\n" 
}>>OUTPUT/ix-tmp/"$ORDER"-REPORT.txt

# Grabbring serial number from IP.txt

touch OUTPUT/ix-tmp/system-serial-output.txt

FILE=SCRIPTS/KEY.txt
SERIAL=""
exec 3<&0
exec 0<$FILE
while read -r line; do
  SERIAL=$(echo "$line" | cut -d " " -f1)

  echo "$SERIAL" >>OUTPUT/ix-tmp/swqc-output.txt

  echo "IP.txt System-Serial is $SERIAL"

  echo "$SERIAL" >OUTPUT/ix-tmp/system-serial-output.txt

  touch OUTPUT/ix-tmp/"$ORDER"-PBS-output.txt
  touch OUTPUT/ix-tmp/"$SERIAL"-username.txt
  touch OUTPUT/ix-tmp/IP.txt

  echo "==========================================================================" >>OUTPUT/ix-tmp/swqc-output.txt

  # Grabbing Burn-In information from PBS logs

  curl -ks https://<PBS_ARCHIVE_HOST>/pbsv4/logs/"$SERIAL"/ | tail -3 | head -1 | cut -c10-24 >OUTPUT/ix-tmp/"$SERIAL"-dir.txt

  if cat OUTPUT/ix-tmp/"$SERIAL"-dir.txt | cut -d '"' -f1 | sed "s,/$,," | grep -Fwqi -e "Debug"; then
    curl -ks https://<PBS_ARCHIVE_HOST>/pbsv4/logs/"$SERIAL"/ | tail -4 | head -1 | cut -c10-24 >OUTPUT/ix-tmp/"$SERIAL"-dir.txt
    PBSDIRECTORY=$(cat OUTPUT/ix-tmp/"$SERIAL"-dir.txt)
    curl https://<PBS_ARCHIVE_HOST>/pbsv4/logs/"$SERIAL"/"$PBSDIRECTORY"/ipmi_summary.txt -o OUTPUT/ix-tmp/"$SERIAL"-PBS-ipmi_summary.txt || curl https://<PBS_ARCHIVE_HOST>/pbsv4/logs/"$SERIAL"/"$PBSDIRECTORY"/ipmi_lan.txt -o OUTPUT/ix-tmp/"$SERIAL"-PBS-ipmi_summary.txt
    

  elif PBSDIRECTORY=$(cat OUTPUT/ix-tmp/"$SERIAL"-dir.txt); then
    echo "$PBSDIRECTORY" >OUTPUT/ix-tmp/test1.txt
    curl https://<PBS_ARCHIVE_HOST>/pbsv4/logs/"$SERIAL"/"$PBSDIRECTORY"/ipmi_summary.txt -o OUTPUT/ix-tmp/"$SERIAL"-PBS-ipmi_summary.txt ||curl https://<PBS_ARCHIVE_HOST>/pbsv4/logs/"$SERIAL"/"$PBSDIRECTORY"/ipmi_lan.txt -o OUTPUT/ix-tmp/"$SERIAL"-PBS-ipmi_summary.txt

  fi

  # Grabbing Passmark Log

  curl https://<PBS_ARCHIVE_HOST>/pbsv4/logs/"$SERIAL"/"$PBSDIRECTORY"/Passmark_Log.html -o OUTPUT/ix-tmp/"$SERIAL"-Passmark_Log.html
  lynx --dump OUTPUT/ix-tmp/"$SERIAL"-Passmark_Log.html | grep -F "TEST RUN" >OUTPUT/ix-tmp/"$SERIAL"-test-run.txt
  tr -s ' ' <OUTPUT/ix-tmp/"$SERIAL"-test-run.txt | cut -d ' ' -f 4 >OUTPUT/ix-tmp/"$SERIAL"-pf.txt

  PASSFAIL=$(cat OUTPUT/ix-tmp/"$SERIAL"-pf.txt | xargs)

  if echo "$PASSFAIL" | grep -oh "\w*PASSED\w*" | grep -Fwqi -e PASSED; then
    echo "[PASSED]" >OUTPUT/ix-tmp/"$SERIAL"-passed.txt
  fi

  PASSVER=$(cat OUTPUT/ix-tmp/"$SERIAL"-passed.txt)

  curl https://<PBS_ARCHIVE_HOST>/pbsv4/logs/"$SERIAL"/"$PBSDIRECTORY"/Passmark_Log.html -o OUTPUT/ix-tmp/"$SERIAL"-Passmark_Log.html
  echo "https://<PBS_ARCHIVE_HOST>/pbsv4/logs/$SERIAL/$PBSDIRECTORY/Passmark_Log.html" >OUTPUT/ix-tmp/"$SERIAL"-CERT.txt
  CERT=$(cat OUTPUT/ix-tmp/"$SERIAL"-CERT.txt)

  # CPU presence check

  curl https://<PBS_ARCHIVE_HOST>/pbsv4/logs/"$SERIAL"/"$PBSDIRECTORY"/temperatures.csv -o OUTPUT/ix-tmp/"$SERIAL"-ipmi_lan.txt

  lynx --dump OUTPUT/ix-tmp/"$SERIAL"-Passmark_Log.html | grep -Ei 'CPU 0|CPU 1' >OUTPUT/ix-tmp/"$SERIAL"-CPU-presence.txt
  if ! [ -s OUTPUT/ix-tmp/"$SERIAL"-CPU-presence.txt ]; then
    echo "[NO CPU TEMP DETECTED]" >OUTPUT/ix-tmp/"$SERIAL"-NO-CPU-presence.txt
  fi

  NOCPUTEMP=$(cat OUTPUT/ix-tmp/"$SERIAL"-NO-CPU-presence.txt)

  # CPU temp check

  lynx --dump OUTPUT/ix-tmp/"$SERIAL"-Passmark_Log.html | grep -Ei 'CPU 0|CPU 1' >OUTPUT/ix-tmp/"$SERIAL"-CPU-temp.txt
  cat OUTPUT/ix-tmp/"$SERIAL"-CPU-temp.txt | xargs | cut -d " " -f6 | cut -c 1-2 >OUTPUT/ix-tmp/"$SERIAL"-CPU-max.txt
  read -r num <OUTPUT/ix-tmp/"$SERIAL"-CPU-max.txt
  if [[ "$num" -gt 89 ]]; then
    echo "[CPU TEMP ABOVE THRESHOLD]" >OUTPUT/ix-tmp/"$SERIAL"-CPU-error.txt
  else
    echo "[CPU TEMP OK]" >OUTPUT/ix-tmp/"$SERIAL"-CPU-error.txt
  fi

  CPUTEMP=$(cat OUTPUT/ix-tmp/"$SERIAL"-CPU-error.txt)

  # Checking to ensure system ran with test disk

  lynx --dump OUTPUT/ix-tmp/"$SERIAL"-Passmark_Log.html | grep -F "Disk (00)" >OUTPUT/ix-tmp/"$SERIAL"-disk00-pf.txt
  DISK00PF=$(cat OUTPUT/ix-tmp/"$SERIAL"-disk00-pf.txt | xargs)

  # Collects test duration

  lynx --dump OUTPUT/ix-tmp/"$SERIAL"-Passmark_Log.html | grep -F "Test Duration" >OUTPUT/ix-tmp/"$SERIAL"-testduration-pf.txt
  TESTDURATION=$(cat OUTPUT/ix-tmp/"$SERIAL"-testduration-pf.txt | xargs)

  curl https://<PBS_ARCHIVE_HOST>/pbsv4/logs/"$SERIAL"/"$PBSDIRECTORY"/ipmi_lan.txt -o OUTPUT/ix-tmp/"$SERIAL"-ipmi_lan.txt

  cat OUTPUT/ix-tmp/"$SERIAL"-ipmi_lan.txt | grep -Ei "IP Address              : " | cut -d ":" -f2 >OUTPUT/ix-tmp/"$SERIAL"-ipmi-ipadddress.txt
  IPMIIP=$(cat OUTPUT/ix-tmp/"$SERIAL"-ipmi-ipadddress.txt | xargs)

  # Collect IPMI IP address

  cat OUTPUT/ix-tmp/"$SERIAL"-ipmi_lan.txt | grep -Ei "MAC Address             : " | xargs | cut -d ' ' -f 4 >OUTPUT/ix-tmp/"$SERIAL"-ipmi-bmc-mac.txt
  IPMIMAC=$(cat OUTPUT/ix-tmp/"$SERIAL"-ipmi-bmc-mac.txt)

  # Collecting STD info

  psql -h <DB_HOST> -U <DB_USER> -d <DB_NAME> -c "select c.name, a.model, a.serial, a.rma, a.revision, a.support_number from production_part a, production_system b, production_type c, production_configuration d where a.system_id = b.id and a.type_id = c.id and b.config_name_id = d.id and b.system_serial = '$SERIAL' order by b.system_serial, a.type_id, a.model, a.serial;" >OUTPUT/ix-tmp/"$SERIAL"-std-parts.txt
  cat OUTPUT/ix-tmp/"$SERIAL"-std-parts.txt | grep -i "IPMI Password" | cut -d "|" -f2-3 | tr -d "|" >OUTPUT/ix-tmp/"$SERIAL"-ipmi-password.txt
  tr -s ' ' <OUTPUT/ix-tmp/"$SERIAL"-ipmi-password.txt | cut -d ' ' -f4 >OUTPUT/ix-tmp/"$SERIAL"-ipmi-pw.txt
  IPMIPASSWORD=$(cat OUTPUT/ix-tmp/"$SERIAL"-ipmi-pw.txt)

  # Checking for break-out cable

  cat OUTPUT/ix-tmp/"$SERIAL"-std-parts.txt | grep -i cable >OUTPUT/ix-tmp/"$SERIAL"-networkcable.txt

  cat OUTPUT/ix-tmp/"$SERIAL"-networkcable.txt | cut -d "|" -f1 >OUTPUT/ix-tmp/"$SERIAL"-networkcable-cp.txt
  cat OUTPUT/ix-tmp/"$SERIAL"-networkcable.txt | cut -d "|" -f2 >OUTPUT/ix-tmp/"$SERIAL"-networkcable-model.txt
  cat OUTPUT/ix-tmp/"$SERIAL"-networkcable.txt | cut -d "|" -f3 >OUTPUT/ix-tmp/"$SERIAL"-networkcable-serial.txt

  NETCABCP=$(cat OUTPUT/ix-tmp/"$SERIAL"-networkcable-cp.txt)
  NETCABMODEL=$(cat OUTPUT/ix-tmp/"$SERIAL"-networkcable-model.txt)

  if echo $NETCABCP | grep -oh "\w*CABLE\w*" | grep -Fwqi -e CABLE; then
    echo "Network Cable $NETCABMODEL Present Check If NIC Is Configure For Break Out" >>OUTPUT/ix-tmp/swqc-output.txt
    echo "[BREAK-OUT CABLE]" >OUTPUT/ix-tmp/"$SERIAL"-break-out.txt
  fi

  BREAKOUT=$(cat OUTPUT/ix-tmp/"$SERIAL"-break-out.txt)

  # Getting motherboard manufacturer info

  lynx --dump OUTPUT/ix-tmp/"$SERIAL"-Passmark_Log.html | grep -F "Motherboard Manufacturer:" | xargs | cut -d ' ' -f3 >OUTPUT/ix-tmp/"$SERIAL"-motherboard-manufacturer.txt
  MOTHERMAN=$(cat OUTPUT/ix-tmp/"$SERIAL"-motherboard-manufacturer.txt)

  # Getting system model type

  lynx --dump OUTPUT/ix-tmp/"$SERIAL"-Passmark_Log.html | grep -F "Motherboard Model:" | xargs | cut -d " " -f3 >OUTPUT/ix-tmp/"$SERIAL"-system-model.txt
  MODELTYPE=$(cat OUTPUT/ix-tmp/"$SERIAL"-system-model.txt)

  # Checking for wrong memory serial for TrueNAS systems

  #curl https://<PBS_ARCHIVE_HOST>/pbsv4/logs/"$SERIAL"/"$PBSDIRECTORY"/DIMM_MemoryChipData.txt -o OUTPUT/ix-tmp/"$SERIAL"-PBS-DIMM_MemoryChipData.txt
  #cat OUTPUT/ix-tmp/"$SERIAL"-PBS-DIMM_MemoryChipData.txt | grep -i 'XF' > OUTPUT/ix-tmp/"$SERIAL"-Mem-Check.txt
  #MEMSERIALCHECK=$(cat OUTPUT/ix-tmp/"$SERIAL"-Mem-Check.txt)
  #if echo "$MEMSERIALCHECK" | grep -Fwqi -e 'XF' ; then
  #    echo "[NVDIMM ERROR]" > OUTPUT/ix-tmp/Mem-Error.txt
  #else
  #    echo "[CORRECT NVDIMM]" > OUTPUT/ix-tmp/Mem-Error.txt
  #fi

  #MEMERROR=$(cat OUTPUT/ix-tmp/Mem-Error.txt)

  # Check for presence of QLOGIC fibre card

  psql -h <DB_HOST> -U <DB_USER> -d <DB_NAME> -c "select c.name, a.model, a.serial, a.rma, a.revision, a.support_number from production_part a, production_system b, production_type c, production_configuration d where a.system_id = b.id and a.type_id = c.id and b.config_name_id = d.id and b.system_serial = '$SERIAL' order by b.system_serial, a.type_id, a.model, a.serial;" >OUTPUT/ix-tmp/"$SERIAL"-std-parts.txt
  cat OUTPUT/ix-tmp/"$SERIAL"-std-parts.txt | grep -i QLE | cut -d "|" -f2 | grep -i -o -P '.{0,0}qle.{0,0}' >OUTPUT/ix-tmp/"$SERIAL"-qle-output.txt

  QLE=$(cat OUTPUT/ix-tmp/"$SERIAL"-qle-output.txt)

  if echo "$QLE" | grep -Fwqi -e QLE; then

    echo "QLOGIC-CARD-Present-Check-TrueNAS-License" >OUTPUT/ix-tmp/"$SERIAL"-qlogic-check.txt
    echo "[QLOGIC/FC]" >OUTPUT/ix-tmp/"$SERIAL"-qlogic-msg.txt
    QLOGIC=$(cat OUTPUT/ix-tmp/"$SERIAL"-qlogic-msg.txt)

  fi

  echo "==========================================================================" >>OUTPUT/ix-tmp/swqc-output.txt

  # Reseting GIGABYTE IPMI to default

  if echo "$MOTHERMAN" | grep -Fwqi -e GIGABYTE; then
    echo "admin" >OUTPUT/ix-tmp/"$SERIAL"-username.txt

    ipmitool -I lanplus -H "$IPMIIP" -U admin -P password user set password 2 "$IPMIPASSWORD"

    sleep 1

    # Check password change completed

    ipmitool -I lanplus -H "$IPMIIP" -U admin -P "$IPMIPASSWORD" lan print 1 >OUTPUT/ix-tmp/"$SERIAL"-passwdcheck.txt

    tr -s ' ' <OUTPUT/ix-tmp/"$SERIAL"-passwdcheck.txt | grep -i Complete | cut -d " " -f6 >OUTPUT/ix-tmp/"$SERIAL"-pwc.txt
    PWC=$(cat OUTPUT/ix-tmp/"$SERIAL"-pwc.txt)

  fi

  # Check for alternate default password

  if ! [ -s OUTPUT/ix-tmp/"$SERIAL"-passwdcheck.txt ]; then
    ipmitool -I lanplus -H "$IPMIIP" -U admin -P administrator user set password 2 "$IPMIPASSWORD" && ipmitool -I lanplus -H "$IPMIIP" -U admin -P "$IPMIPASSWORD" lan print 1 >OUTPUT/ix-tmp/"$SERIAL"-passwdcheck.txt
    tr -s ' ' <OUTPUT/ix-tmp/"$SERIAL"-passwdcheck.txt | grep -i Complete | cut -d " " -f6 >OUTPUT/ix-tmp/"$SERIAL"-pwc.txt
    PWC=$(cat OUTPUT/ix-tmp/"$SERIAL"-pwc.txt)

  fi

  # Verify password changed

  if echo "$MOTHERMAN" | grep -Fwqi -e GIGABYTE && echo "$PWC" | grep -oh "\w*Complete\w*" | grep -Fwqi -e Complete; then
    echo "[PWD VERIFIED]" >OUTPUT/ix-tmp/pwd-verified.txt
    PWDV=$(cat OUTPUT/ix-tmp/pwd-verified.txt)

  fi

  echo "==========================================================================" >>OUTPUT/ix-tmp/swqc-output.txt

  # IPMIUSER changes based on motherboard manufacturer

  IPMIUSER=$(cat OUTPUT/ix-tmp/"$SERIAL"-username.txt)

  echo "==========================================================================" >>OUTPUT/ix-tmp/swqc-output.txt

  mkdir OUTPUT/ix-tmp/PBS_LOGS
  wget -np -r -nH --cut-dirs=4 https://<PBS_ARCHIVE_HOST>/pbsv4/logs/"$SERIAL"/"$PBSDIRECTORY"/ -P OUTPUT/ix-tmp/PBS_LOGS/

  # Grabbing MAC address for Asset List

  touch OUTPUT/ix-tmp/mac-address-list.txt
  {
    echo -e "==========================================================================\n";
    echo -e "$SERIAL MELLANOX CHECK:\n\n" >>OUTPUT/ix-tmp/mac-address-list.txt
    cat OUTPUT/ix-tmp/"$SERIAL"-ifconfig.txt | grep -i -A3 -B1 mellanox | xargs -0 | sed 's/^ *//g';
    echo -e "\n==========================================================================\n";
    echo -e "$SERIAL IPMI:\n\n";
    cat OUTPUT/ix-tmp/"$SERIAL"-ipmi_lan.txt | grep "MAC Address             :" | sed "s/://g";
    echo -e "\n==========================================================================\n";
    echo -e "$SERIAL ONBOARD NICS:\n\n";
    cat OUTPUT/ix-tmp/"$SERIAL"-ifconfig.txt | grep -EA5 -i --color '(o1:|o2:)' | xargs -0 | sed 's/^ *//g';
    echo -e "\n==========================================================================";
    sed "/A1-/! s/-//g";
  }>OUTPUT/ix-tmp/fixed-mac-address-list.txt

  # Grabbing SEL, SDR, & SENSOR info

  yes | pv -SpeL1 -s 45 >/dev/null

  ipmitool -I lanplus -H "$IPMIIP" -U "$IPMIUSER" -P "$IPMIPASSWORD" sel list >OUTPUT/ix-tmp/"$SERIAL"-SEL-Data.txt
  if ! [ -s OUTPUT/ix-tmp/"$SERIAL"-SEL-Data.txt ]; then
    ipmitool -H "$IPMIIP" -U "$IPMIUSER" -P "$IPMIPASSWORD" sel list >OUTPUT/ix-tmp/"$SERIAL"-SEL-Data.txt
  fi

  ipmitool -I lanplus -H "$IPMIIP" -U "$IPMIUSER" -P "$IPMIPASSWORD" sdr list >OUTPUT/ix-tmp/"$SERIAL"-SDR-Data.txt
  if ! [ -s OUTPUT/ix-tmp/"$SERIAL"-SDR-Data.txt ]; then
    ipmitool -H "$IPMIIP" -U "$IPMIUSER" -P "$IPMIPASSWORD" sdr list >OUTPUT/ix-tmp/"$SERIAL"-SDR-Data.txt
  fi

  ipmitool -I lanplus -H "$IPMIIP" -U "$IPMIUSER" -P "$IPMIPASSWORD" sensor list >OUTPUT/ix-tmp/"$SERIAL"-SENSOR-Data.txt
  if ! [ -s OUTPUT/ix-tmp/"$SERIAL"-SENSOR-Data.txt ]; then
    ipmitool -H "$IPMIIP" -U "$IPMIUSER" -P "$IPMIPASSWORD" sensor list >OUTPUT/ix-tmp/"$SERIAL"-SENSOR-Data.txt
  fi

  # Check for missing fans

  if echo "$MODELTYPE" | grep -Fwqi -e IX-4224GP2-IXN; then
    cat OUTPUT/ix-tmp/"$SERIAL"-SDR-Data.txt | grep -i -v "FAN10" | grep -i 'FAN[17]' >OUTPUT/ix-tmp/"$SERIAL"-FAN-Data.txt
  fi

  if cat OUTPUT/ix-tmp/"$SERIAL"-FAN-Data.txt | grep "no reading"; then
    echo "[CHECK FANS]" >OUTPUT/ix-tmp/"$SERIAL"-FAN-Check.txt
  fi

  FANERROR=$(cat OUTPUT/ix-tmp/"$SERIAL"-FAN-Check.txt)

  # Dumping data to consolidated output file

  echo "$SERIAL $IPMIIP $IPMIMAC $PASSFAIL $DISK00PF $TESTDURATION $FANERROR $MEMERROR $IPMIPASSWORD $PWDV $MOTHERMAN $MODELTYPE $BREAKOUT $CPUTEMP $NOCPUTEMP $MINIEFANERROR $QLOGIC" | xargs >>OUTPUT/ix-tmp/"$ORDER"-PBS-output.txt

  echo -e "===========================================================================\nSERIAL NUMBER:\n$SERIAL\n\n===========================================================================\nIPMI IP:\n$IPMIIP\n\n===========================================================================\nIPMI USER:\n$IPMIUSER\n\n===========================================================================\nIPMI PASSWORD:\n$IPMIPASSWORD\n$PWDV\n\n===========================================================================\nIPMI MAC ADDRESS:\n$IPMIMAC\n\n===========================================================================\nBURN-IN RESULTS:\n$PASSVER\n$DISK00PF\n$TESTDURATION\n\n$CERT\n\n===========================================================================\nSYSTEM INFO:\n$MOTHERMAN\n$MODELTYPE \n\n===========================================================================\nCONFIGURATIONS:\n$NETSET\n$FANSET\n\n===========================================================================\nSYSTEM WARNINGS:\n$CPUTEMP\n$MEMERROR\n$NOCPUTEMP\n$BREAKOUT\n$QLOGIC\n$FANERROR\n$MINIEFANERROR\n" >>OUTPUT/ix-tmp/"$ORDER"-REPORT.txt
  echo -e "\n\n------------------------------------END------------------------------------\n\n\n" >>OUTPUT/ix-tmp/"$ORDER"-REPORT.txt

  echo "$SERIAL $IPMIIP $IPMIUSER $IPMIPASSWORD $IPMIMAC" >>OUTPUT/ix-tmp/IP.txt

done

# Creating CSV file for data transfer

tr -s " " <OUTPUT/ix-tmp/IP.txt >OUTPUT/ix-tmp/IP.csv

echo "==========================================================================" >>OUTPUT/ix-tmp/swqc-output.txt

# Creating GOLD file for diff

LINE=$(head -n 1 SCRIPTS/KEY.txt)

cp OUTPUT/ix-tmp/"$LINE"-SEL-Data.txt OUTPUT/ix-tmp/GOLD-SEL-Data.txt
cp OUTPUT/ix-tmp/"$LINE"-SDR-Data.txt OUTPUT/ix-tmp/GOLD-SDR-Data.txt
cp OUTPUT/ix-tmp/"$LINE"-SENSOR-Data.txt OUTPUT/ix-tmp/GOLD-SENSOR-Data.txt

# Diffing each system for errors

FILE=SCRIPTS/KEY.txt
SERIAL=""
exec 3<&0
exec 0<$FILE
while read -r line; do
  SERIAL=$(echo "$line" | cut -d " " -f 1)

  echo "------------------------------------------------------$SERIAL------------------------------------------------------" >>OUTPUT/ix-tmp/SEL-DIFF.txt
  diff -y -W 200 --suppress-common-lines OUTPUT/ix-tmp/GOLD-SEL-Data.txt OUTPUT/ix-tmp/"$SERIAL"-SEL-Data.txt >>OUTPUT/ix-tmp/SEL-DIFF.txt

  echo "------------------------------------------------------$SERIAL------------------------------------------------------" >>OUTPUT/ix-tmp/SDR-DIFF.txt
  diff -y -W 200 --suppress-common-lines OUTPUT/ix-tmp/GOLD-SDR-Data.txt OUTPUT/ix-tmp/"$SERIAL"-SDR-Data.txt >>OUTPUT/ix-tmp/SDR-DIFF.txt

  echo "------------------------------------------------------$SERIAL------------------------------------------------------" >>OUTPUT/ix-tmp/SENSOR-DIFF.txt
  diff -y -W 200 --suppress-common-lines OUTPUT/ix-tmp/GOLD-SENSOR-Data.txt OUTPUT/ix-tmp/"$SERIAL"-SENSOR-Data.txt >>OUTPUT/ix-tmp/SENSOR-DIFF.txt

done

echo "=====================================END=====================================" >>OUTPUT/ix-tmp/swqc-output.txt

mv OUTPUT/ix-tmp OUTPUT/"$ORDER"-CC-CONF

# Compress output file

tar cfz "OUTPUT/$ORDER-CC-CONF.tar.gz" OUTPUT/"$ORDER"-CC-CONF

exit
