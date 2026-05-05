#! /bin/bash

mkdir OUTPUT/redfish-tmp
cp ~/3-iX-WSL-CC/SCRIPTS/KEY.txt OUTPUT/redfish-tmp/Input.txt

echo "[EXPORTING BIOS FILES]"

FILE=OUTPUT/redfish-tmp/Input.txt
while read -r LINE; do
    IPMIIP="$(echo "$LINE" | cut -d " " -f 1)"

    cd ~/3-iX-WSL-CC/SWQC/hrt-liquid-redfish || exit
    python3 hrt_bios_check.py "$IPMIIP"

done <$FILE

echo "[EXPORT COMPLETE]"
yes | pv -SpeL1 -s 3 > /dev/null
cd ~/3-iX-WSL-CC/SWQC/hrt-liquid-redfish || exit
mkdir BiosCfg
mv -- *Settings.json ~/3-iX-WSL-CC/SWQC/hrt-liquid-redfish/BiosCfg
tar cfz "BiosCfg.tar.gz" BiosCfg
rm -rf ~/3-iX-WSL-CC/OUTPUT/redfish-tmp

exit
