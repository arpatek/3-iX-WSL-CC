#!/bin/bash
# Title: VRSGN-AMD-1123US-TR4-V.08.sh
# Description: LiquidPC configuration setup
# Author: jgarcia@ixsystems.com
# Updated: 03-13-23
# Version: 1.0
#########################################################################################################


# Removing Previous Temp Folder

rm -rf OUTPUT/VRSGN-tmp

# This Is The Directories Where The Data We Collect Will Go

mkdir OUTPUT/VRSGN-tmp

# Collecting Name Of Person Performing CC

dialog --inputbox "Enter The Name Of The Person Performing CC Here" 10 60 2>OUTPUT/VRSGN-tmp/CC-Person.txt

# Collecting Order Number For Systems

dialog --inputbox "Enter Order Number" 10 60 2>OUTPUT/VRSGN-tmp/Order-Num.txt
ORDER=$(cat OUTPUT/VRSGN-tmp/Order-Num.txt)

# Removing Previous Files

rm -rf OUTPUT/"$ORDER"-VRSGN-AMD-1123US-TR4-V.08.tar.gz OUTPUT/"$ORDER"-VRSGN-AMD-1123US-TR4-V.08

clear

VRSGNPWD=<VRSGN_DEFAULT_PASSWORD>

echo "==========================================================================" >>OUTPUT/VRSGN-tmp/LINE-Output.txt

cp ~/3-iX-WSL-CC/SCRIPTS/KEY.txt OUTPUT/VRSGN-tmp/Input.txt

FILE=OUTPUT/VRSGN-tmp/Input.txt
SERIAL=""
exec 3<&0
exec 0<"$FILE"
while read -r LINE; do
  SERIAL=$(echo "$LINE" | cut -d " " -f1)

  # Grabbing Burn-In Information From PBS Logs

  lynx --dump https://<PBS_ARCHIVE_HOST>/pbsv4/logs/"$SERIAL"/ | tail -1 | cut -d "/" -f7 >OUTPUT/VRSGN-tmp/"$SERIAL"-DIR.txt
  PBSDIRECTORY=$(cat OUTPUT/VRSGN-tmp/"$SERIAL"-DIR.txt)
  curl https://<PBS_ARCHIVE_HOST>/pbsv4/logs/"$SERIAL"/"$PBSDIRECTORY"/ipmi_summary.txt -o OUTPUT/VRSGN-tmp/"$SERIAL"-PBS-IPMI_Summary.txt

  if PBSDIRECTORY=$(cat OUTPUT/VRSGN-tmp/"$SERIAL"-DIR.txt); then
    echo "$PBSDIRECTORY" >OUTPUT/VRSGN-tmp/"$SERIAL"-DIR-Check.txt
    curl https://<PBS_ARCHIVE_HOST>/pbsv4/logs/"$SERIAL"/"$PBSDIRECTORY"/ipmi_summary.txt -o OUTPUT/VRSGN-tmp/"$SERIAL"-PBS-IPMI_Summary.txt

  fi

  # Grabbing Passmark Log

  curl https://<PBS_ARCHIVE_HOST>/pbsv4/logs/"$SERIAL"/"$PBSDIRECTORY"/Passmark_Log.cert.htm -o OUTPUT/VRSGN-tmp/"$SERIAL"-PBS-Passmark_Log.cert.htm
  lynx --dump OUTPUT/VRSGN-tmp/"$SERIAL"-PBS-Passmark_Log.cert.htm >OUTPUT/VRSGN-tmp/"$SERIAL"-Lynx-Cert.txt
  cat OUTPUT/VRSGN-tmp/"$SERIAL"-Lynx-Cert.txt
  lynx --dump OUTPUT/VRSGN-tmp/"$SERIAL"-PBS-Passmark_Log.cert.htm | grep -F "TEST RUN" >OUTPUT/VRSGN-tmp/"$SERIAL"-Test-Run.txt
  tr -s ' ' <OUTPUT/VRSGN-tmp/"$SERIAL"-Test-Run.txt | cut -d ' ' -f 4 | awk '{$1=$1};1' >OUTPUT/VRSGN-tmp/"$SERIAL"-PF.txt
  PASSFAIL=$(cat OUTPUT/VRSGN-tmp/"$SERIAL"-PF.txt)

  if [[ "$PASSFAIL" == "PASSED" ]]; then
    echo "[PASSED]" >OUTPUT/VRSGN-tmp/"$SERIAL"-Passed.txt
  elif [[ "$PASSFAIL" == "FAILED" ]]; then
    echo "[FAILED]" >OUTPUT/VRSGN-tmp/"$SERIAL"-Passed.txt
  fi

  PASSVER=$(cat OUTPUT/VRSGN-tmp/"$SERIAL"-Passed.txt)

  # Checking to ensure system ran with test disk

  lynx --dump OUTPUT/VRSGN-tmp/"$SERIAL"-PBS-Passmark_Log.cert.htm | grep ") PASS" | sed -n 2p | awk '{$1=$1};1' >OUTPUT/VRSGN-tmp/"$SERIAL"-Disk00.txt
  DISK00PF=$(cat OUTPUT/VRSGN-tmp/"$SERIAL"-Disk00.txt)

  # Collecting test duration

  lynx --dump OUTPUT/VRSGN-tmp/"$SERIAL"-PBS-Passmark_Log.cert.htm | grep -F "Test Duration" | awk '{$1=$1};1' >OUTPUT/VRSGN-tmp/"$SERIAL"-Test-Duration.txt
  TESTDURATION=$(cat OUTPUT/VRSGN-tmp/"$SERIAL"-Test-Duration.txt)

  # Collecting IPMI IP Address

  sed -e "s/\r//g" OUTPUT/VRSGN-tmp/"$SERIAL"-PBS-IPMI_Summary.txt >OUTPUT/VRSGN-tmp/"$SERIAL"-IPMI-Summary.txt

  grep <OUTPUT/VRSGN-tmp/"$SERIAL"-IPMI-Summary.txt -E -i "IPv4 Address           : " | cut -d ":" -f2 | xargs >OUTPUT/VRSGN-tmp/"$SERIAL"-IPMI-IPAdddress.txt
  IPMIIP=$(cat OUTPUT/VRSGN-tmp/"$SERIAL"-IPMI-IPAdddress.txt)

  # Collecting IPMI MAC address

  grep <OUTPUT/VRSGN-tmp/"$SERIAL"-IPMI-Summary.txt -E -i "BMC MAC Address" | tr -s ' ' | cut -d " " -f5 >OUTPUT/VRSGN-tmp/"$SERIAL"-BMC-MAC.txt
  IPMIMAC=$(cat OUTPUT/VRSGN-tmp/"$SERIAL"-BMC-MAC.txt)

  # Collecting STD Password

  psql -h <DB_HOST> -U <DB_USER> -d <DB_NAME> -c "select c.name, a.model, a.serial, a.rma, a.revision, a.support_number from production_part a, production_system b, production_type c, production_configuration d where a.system_id = b.id and a.type_id = c.id and b.config_name_id = d.id and b.system_serial = '$SERIAL' order by b.system_serial, a.type_id, a.model, a.serial;" >~/3-iX-WSL-CC/OUTPUT/VRSGN-tmp/"$SERIAL"-STD-Parts.txt
  cat < OUTPUT/VRSGN-tmp/"$SERIAL"-STD-Parts.txt | grep "Unique Password" | cut -d "|" -f3 | xargs >OUTPUT/VRSGN-tmp/"$SERIAL"-IPMI-Password.txt
  IPMIPASSWORD=$(cat OUTPUT/VRSGN-tmp/"$SERIAL"-IPMI-Password.txt)

  echo "==========================================================================" >>OUTPUT/VRSGN-tmp/LINE-Output.txt

  # Changing Default Password & User

  echo "User: root Password: $VRSGNPWD" >OUTPUT/VRSGN-tmp/"$ORDER"-VRSGNPWD.txt

  ipmitool -I lanplus -H "$IPMIIP" -U ADMIN -P "$IPMIPASSWORD" user set name 2 root #|| ipmitool -I lanplus -H "$IPMIIP" -U ADMIN -P ADMIN user set name 2 root &>>OUTPUT/VRSGN-tmp/"$SERIAL"-Root-User.txt

  ipmitool -I lanplus -H "$IPMIIP" -U root -P "$IPMIPASSWORD" user set password 2 $VRSGNPWD 20 || ipmitool -I lanplus -H "$IPMIIP" -U root -P ADMIN user set password 2 $VRSGNPWD 20 &>>OUTPUT/VRSGN-tmp/"$SERIAL"-PWD-Set.txt

  ipmitool -I lanplus -H "$IPMIIP" -U root -P $VRSGNPWD lan print 1

  ipmitool -I lanplus -H "$IPMIIP" -U root -P "$VRSGNPWD" lan print 1 | grep -i "Complete" | tr -s ' ' | cut -d " " -f 6 >>OUTPUT/VRSGN-tmp/"$SERIAL"-PWC.txt
  PWC=$(cat OUTPUT/VRSGN-tmp/"$SERIAL"-PWC.txt)

  echo "$SERIAL-VRSGN-AMD-CFG-$PWC" >>OUTPUT/VRSGN-tmp/"$ORDER"-VRSGN-CFG.txt
  echo "$SERIAL,$PASSVER,$DISK00PF,$TESTDURATION,$IPMIIP,$IPMIUSER,$IPMIPASSWORD,$IPMIMAC" >>OUTPUT/VRSGN-tmp/"$ORDER"-IPMI.txt
  column <OUTPUT/VRSGN-tmp/"$ORDER"-IPMI.txt -t -s "," -o " " >OUTPUT/VRSGN-tmp/"$ORDER"-PBS-OUT.txt

  ipmitool -I lanplus -H "$IPMIIP" -U root -P $VRSGNPWD chassis bootparam set bootflag force_bios

done

echo "==========================================================================" >>OUTPUT/VRSGN-tmp/LINE-Output.txt

mv OUTPUT/"VRSGN-tmp" OUTPUT/"$ORDER-VRSGN-AMD-1123US-TR4-V.08"

# Compress Output File

tar cfz OUTPUT/"$ORDER-VRSGN-AMD-1123US-TR4-V.08.tar.gz" OUTPUT/"$ORDER-VRSGN-AMD-1123US-TR4-V.08"

exit
