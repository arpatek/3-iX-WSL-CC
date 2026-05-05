#!/bin/bash
# Title: True-Diff.sh
# Description: Diff for diffme files
# Author: jgarcia@ixsystems.com
# Updated: 03:15:2023
# Version: 1.0
#########################################################################################################

mkdir OUTPUT/diff-tmp

# Collecting Name Of Person Performing CC

dialog --inputbox "Enter The Name Of The Person Performing CC Here" 10 60 2>OUTPUT/diff-tmp/CC-Person.txt


# Collecting Order Number For Systems

dialog --inputbox "Enter Order Number" 10 60 2>OUTPUT/diff-tmp/ORDER-Num.txt
ORDER=$(cat OUTPUT/diff-tmp/ORDER-Num.txt)

# Removing Previous Files

rm -rf OUTPUT/"$ORDER"-TRUE-DIFF.tar.gz OUTPUT/"$ORDER"-TRUE-DIFF
clear


echo "==========================================================================" >> OUTPUT/diff-tmp/LINE-Output.txt


echo "DIFF RESULTS" >> OUTPUT/diff-tmp/"$ORDER"-DIFF-RESULTS.txt
echo -e "Order Number: $ORDER\n\n" >> OUTPUT/diff-tmp/"$ORDER"-DIFF-RESULTS.txt
clear


echo "==========================================================================" >> OUTPUT/diff-tmp/LINE-Output.txt


FILE=SCRIPTS/KEY.txt
SERIAL=""
exec 3<&0
exec 0<$FILE
while read -r LINE
do

SERIAL=$(< "$LINE" cut -d "" -f 1)

echo "$SERIAL" > OUTPUT/diff-tmp/Field1-Output.txt

# Extracting To TMP Folder

tar -zxf TMP/"$SERIAL"-SWQC-OUT.tar.gz --directory TMP/
cp TMP/swqc-tmp/"$SERIAL"-3-iX-SWQC-DIFFME.txt OUTPUT/diff-tmp/

# Creating GOLD File For Diff

LINE=$(head -n 1 SCRIPTS/KEY.txt | xargs)
cp TMP/swqc-tmp/"$LINE"-3-iX-SWQC-DIFFME.txt OUTPUT/diff-tmp/GOLD-DIFF.txt

# Diffing Files

echo "------------------------------------------------------$SERIAL------------------------------------------------------" >> OUTPUT/diff-tmp/"$ORDER"-DIFF-RESULTS.txt
diff -y -W 200 --suppress-common-lines OUTPUT/diff-tmp/GOLD-DIFF.txt TMP/swqc-tmp/"$SERIAL"-3-iX-SWQC-DIFFME.txt >> OUTPUT/diff-tmp/"$ORDER"-DIFF-RESULTS.txt

done


echo "==========================================================================" >> OUTPUT/diff-tmp/LINE-Output.txt

# Clean Up

mv OUTPUT/diff-tmp OUTPUT/"$ORDER"-TRUE-DIFF
tar cfz OUTPUT/"$ORDER-TRUE-DIFF.tar.gz" OUTPUT/"$ORDER"-TRUE-DIFF

rm -rf TMP/*.tar.gz
rm -rf TMP/swqc-tmp

exit
