#!/bin/bash
# Title: HRT-BIOS-DIFF.sh
# Description: Diff for BIOS files
# Author: jgarcia@ixsystems.com
# Updated: 04:18:2023
# Version: 1.0
#########################################################################################################

mkdir OUTPUT/diff-tmp

# Collecting Name Of Person Performing CC

dialog --inputbox "Enter The Name Of The Person Performing CC Here" 10 60 2>OUTPUT/diff-tmp/CC-Person.txt

# Collecting Order Number For Systems

dialog --inputbox "Enter Order Number" 10 60 2>OUTPUT/diff-tmp/Order-Num.txt
ORDER=$(cat OUTPUT/diff-tmp/Order-Num.txt)

# Removing Previous Files

rm -rf OUTPUT/"$ORDER"-HRT-DIFF.tar.gz OUTPUT/"$ORDER"-HRT-DIFF
clear

echo "==========================================================================" >>OUTPUT/diff-tmp/Line-Output.txt

echo "DIFF RESULTS" >>OUTPUT/diff-tmp/"$ORDER"-DIFF-RESULTS.txt
echo -e "Order Number: $ORDER\n\n" >>OUTPUT/diff-tmp/"$ORDER"-DIFF-RESULTS.txt
clear

echo "==========================================================================" >>OUTPUT/diff-tmp/Line-Output.txt

cp ~/3-iX-WSL-CC/SCRIPTS/KEY.txt OUTPUT/diff-tmp/Input.txt

FILE=OUTPUT/diff-tmp/Input.txt
SERIAL=" "
exec 3<&0
exec 0<$FILE
while read -r LINE; do

    SERIAL=$(echo "$LINE" | cut -d " " -f 1)

    echo "$SERIAL" >OUTPUT/diff-tmp/Field1-Output.txt

    # Diffing Files

    echo "------------------------------------------------------$SERIAL------------------------------------------------------" >>OUTPUT/diff-tmp/"$ORDER"-DIFF-RESULTS.txt
    diff -y -W 200 --suppress-common-lines ~/3-iX-WSL-CC/SWQC/hrt-liquid-redfish/HRT_Liquid_BIOS_Golden_Readable.json ~/3-iX-WSL-CC/SWQC/hrt-liquid-redfish/BiosCfg/"$SERIAL"_BIOS_Settings.json >>OUTPUT/diff-tmp/"$ORDER"-DIFF-RESULTS.txt

    echo "[HRT BIOS DIFF DONE FOR $SERIAL]" | pv -qlL3

done

echo "==========================================================================" >>OUTPUT/diff-tmp/Line-Output.txt

# Clean Up
cp ~/3-iX-WSL-CC/SWQC/hrt-liquid-redfish/HRT_Liquid_BIOS_Golden_Readable.json OUTPUT/diff-tmp
mv ~/3-iX-WSL-CC/SWQC/hrt-liquid-redfish/BiosCfg OUTPUT/
mv ~/3-iX-WSL-CC/SWQC/hrt-liquid-redfish/BiosCfg.tar.gz OUTPUT/
mv OUTPUT/diff-tmp OUTPUT/"$ORDER"-HRT-DIFF
tar cfz OUTPUT/"$ORDER-HRT-DIFF.tar.gz" OUTPUT/"$ORDER"-HRT-DIFF

exit
