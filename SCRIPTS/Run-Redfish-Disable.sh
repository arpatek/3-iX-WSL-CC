#! /bin/bash
# Title         :Run-Redfish-Disable
# Description   :Designed To Disable Redfish User
# Author		:Juan Garcia
# Date          :1-19-23
# Version       :1.0
#########################################################################################################


mkdir OUTPUT/redfish-disable-tmp

cp ~/3-iX-WSL-CC/SCRIPTS/KEY.txt OUTPUT/redfish-disable-tmp/Input.txt

FILE=OUTPUT/redfish-disable-tmp/Input.txt
IPMI=""
IPMIPASSWD=""
GUIIP=""
exec 3<&0
exec 0<$FILE
while read -r LINE; do

    IPMI=$(echo "$LINE" | cut -d " " -f 1)
    echo "$IPMI"
    IPMIPASSWD=$(echo "$LINE" | cut -d " " -f 2)
    echo "$IPMIPASSWD"
    GUIIP=$(echo "$LINE" | cut -d " " -f 3)
    echo "$GUIIP"

    echo "=========================================================================="

    # Using sed to add our variables to scripts being run on remote system

    sed -i "s/IPMIIP/$IPMI/g" ~/3-iX-WSL-CC/SCRIPTS/VALIDATION/Redfish-Disable.sh # updating Redfish-Disable.sh via sed to supply IPMI IP

    sed -i "s/IPMIPASSWD/$IPMIPASSWD/g" ~/3-iX-WSL-CC/SCRIPTS/VALIDATION/Redfish-Disable.sh # updating Redfish-Disable.sh to via sed to supply IPMI Password

    echo "=========================================================================="

    # Executing script on remote server over ssh using sshpass

    sshpass <~/3-iX-WSL-CC/SCRIPTS/VALIDATION/Redfish-Disable.sh -vp <TRUENAS_ROOT_PASSWORD> ssh -tt -oStrictHostKeyChecking=no root@"$GUIIP" -yes 

    # Cleanup of script for reusability

    sed -i "s/$IPMI/IPMIIP/g" ~/3-iX-WSL-CC/SCRIPTS/VALIDATION/Redfish-Disable.sh # Reverting sed changed

    sed -i "s/$IPMIPASSWD/IPMIPASSWD/g" ~/3-iX-WSL-CC/SCRIPTS/VALIDATION/Redfish-Disable.sh # Reverting sed changed

done

#rm -rf OUTPUT/redfish-disable-tmp

exit
