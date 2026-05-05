#!/bin/bash
# Title: SEL-SDR-Diff.sh
# Description: Diff for SEL & SDR files
# Author: jgarcia@ixsystems.com
# Updated: 04:27:2023
# Version: 1.0
#########################################################################################################

mkdir OUTPUT/diff-tmp

dialog --inputbox "Enter The Name Of The Person Performing CC Here" 10 60 2>OUTPUT/diff-tmp/CC-Person.txt

# Collecting order number for HRT systems

dialog --inputbox "Enter Order Number" 10 60 2>OUTPUT/diff-tmp/Order-Num.txt
clear
ORDER=$(cat OUTPUT/diff-tmp/Order-Num.txt)

cp ~/3-iX-WSL-CC/SCRIPTS/KEY.txt OUTPUT/diff-tmp/Input.txt

FILE=OUTPUT/diff-tmp/Input.txt
while read -r LINE; do
    SERIAL="$(echo "$LINE" | cut -d " " -f 1)"
    IPMIIP="$(echo "$LINE" | cut -d " " -f 2)"
    IPMIUSER="$(echo "$LINE" | cut -d " " -f 3)"
    IPMIPASSWORD="$(echo "$LINE" | cut -d " " -f 4)"

    ipmitool -I lanplus -H "$IPMIIP" -U "$IPMIUSER" -P "$IPMIPASSWORD" sel list >>OUTPUT/diff-tmp/"$SERIAL"-SEL-INFO.txt
    ipmitool -I lanplus -H "$IPMIIP" -U "$IPMIUSER" -P "$IPMIPASSWORD" sdr list >>OUTPUT/diff-tmp/"$SERIAL"-SDR-INFO.txt

done <$FILE

LINE=$(head -n 1 OUTPUT/diff-tmp/Input.txt | cut -d " " -f 1)

# Making GOLD File

cp OUTPUT/diff-tmp/"$LINE"-SEL-INFO.txt OUTPUT/diff-tmp/GOLD-SEL-INFO.txt
cp OUTPUT/diff-tmp/"$LINE"-SDR-INFO.txt OUTPUT/diff-tmp/GOLD-SDR-INFO.txt

FILE=$(OUTPUT/diff-tmp/Input.txt | cut -d " " -f 1)
while read -r LINE; do

# Diffing Files

echo "------------------------------------------------------$LINE------------------------------------------------------" >>OUTPUT/diff-tmp/3-SEL-DIFF-RESULTS.txt
diff -y -W 200 --suppress-common-lines OUTPUT/diff-tmp/GOLD-SEL-INFO.txt OUTPUT/diff-tmp/"$LINE"-SEL-INFO.txt >>OUTPUT/diff-tmp/3-SEL-DIFF-RESULTS.txt

echo "------------------------------------------------------$LINE------------------------------------------------------" >>OUTPUT/diff-tmp/3-SDR-DIFF-RESULTS.txt
diff -y -W 200 --suppress-common-lines OUTPUT/diff-tmp/GOLD-SDR-INFO.txt OUTPUT/diff-tmp/"$LINE"-SDR-INFO.txt >>OUTPUT/diff-tmp/3-SDR-DIFF-RESULTS.txt

done <"$FILE"

# Clean Up

mv OUTPUT/diff-tmp OUTPUT/"$ORDER"-SENSOR-DIFF
tar cfz OUTPUT/"$ORDER-SENSOR-DIFF.tar.gz" OUTPUT/"$ORDER"-SENSOR-DIFF

exit
