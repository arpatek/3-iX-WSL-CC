#!/bin/bash
# Title         :CM6-Check.sh
# Description   :Designed To Run CM6-Flash.sh
# Author		:Juan Garcia
# Date          :11-11-22
# Version       :1.0
#########################################################################################################

# Grabbring serial number & ip from Input.txt

FILE=~/3-iX-WSL-CC/SCRIPTS/KEY.txt
IP=""
exec 3<&0
exec 0<$FILE
while read -r line; do
    IP=$(echo "$line" | cut -d " " -f 1)

    # Run validation script CM6-Flash.sh
    ssh-keygen -f "/home/$USER/.ssh/known_hosts" -R "$IP"

    cat ~/3-iX-WSL-CC/SCRIPTS/VALIDATION/CM6-Flash.sh | sshpass -vp <TRUENAS_ROOT_PASSWORD> ssh -tt -oStrictHostKeyChecking=no root@"$IP"

done

exit
