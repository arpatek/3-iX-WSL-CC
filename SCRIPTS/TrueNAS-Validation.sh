#!/bin/bash
# Title: TrueNAS-Validation.sh
# Description: Designed To Run System Specific Script For Validation
# Author: Juan Garcia
# Updated: 10-06-22
# Version: 2.0
#########################################################################################################

# This is the directory where the data we collect will go

mkdir OUTPUT/tnas-tmp

# Grabbring serial number & ip from IP.txt

cp ~/3-iX-WSL-CC/SCRIPTS/KEY.txt OUTPUT/tnas-tmp/Input.txt

FILE=OUTPUT/tnas-tmp/Input.txt
SERIAL=""
IP=""
exec 3<&0
exec 0<$FILE
while read -r LINE; do
    SERIAL=$(echo "$LINE" | cut -d " " -f 1)
    IP=$(echo "$LINE" | cut -d " " -f 2)

    # Clearing ssh key from known_hosts file

    ssh-keygen -f "/home/$USER/.ssh/known_hosts" -R "$IP"

    # Grabbing PBS directory

    curl -ks https://<PBS_ARCHIVE_HOST>/pbsv4/logs/"$SERIAL"/ | tail -3 | head -1 | cut -c10-24 >OUTPUT/tnas-tmp/"$SERIAL"-DIR.txt

    if cut <OUTPUT/tnas-tmp/"$SERIAL"-DIR.txt -d '"' -f1 | sed "s,/$,," | grep -Fwqi -e "Debug"; then
        curl -ks https://<PBS_ARCHIVE_HOST>/pbsv4/logs/"$SERIAL"/ | tail -4 | head -1 | cut -c10-24 >OUTPUT/tnas-tmp/"$SERIAL"-DIR.txt
        PBSDIRECTORY=$(cat OUTPUT/tnas-tmp/"$SERIAL"-DIR.txt)
        curl https://<PBS_ARCHIVE_HOST>/pbsv4/logs/"$SERIAL"/"$PBSDIRECTORY"/ipmi_summary.txt -o OUTPUT/tnas-tmp/"$SERIAL"-PBS-IPMI_Summary.txt

    elif PBSDIRECTORY=$(cat OUTPUT/tnas-tmp/"$SERIAL"-DIR.txt); then
        echo "$PBSDIRECTORY" >OUTPUT/tnas-tmp/"$SERIAL"-DIR-Check.txt
        curl https://<PBS_ARCHIVE_HOST>/pbsv4/logs/"$SERIAL"/"$PBSDIRECTORY"/ipmi_summary.txt -o OUTPUT/tnas-tmp/"$SERIAL"-PBS-IPMI_Summary.txt

    fi

    # Grabbing Passmark Logs

    curl https://<PBS_ARCHIVE_HOST>/pbsv4/logs/"$SERIAL"/"$PBSDIRECTORY"/Passmark_Log.cert.htm -o OUTPUT/tnas-tmp/"$SERIAL"-PBS-Passmark_Log.cert.htm
    curl https://<PBS_ARCHIVE_HOST>/pbsv4/logs/"$SERIAL"/"$PBSDIRECTORY"/Passmark_Log.htm -o OUTPUT/tnas-tmp/"$SERIAL"-PBS-Passmark_Log.htm

    # Getting system model type

    lynx --dump OUTPUT/tnas-tmp/"$SERIAL"-PBS-Passmark_Log.htm | grep -F "System Model:" | head -n 1 >OUTPUT/tnas-tmp/"$SERIAL"-System-Model.txt
    cut <OUTPUT/tnas-tmp/"$SERIAL"-System-Model.txt -d " " -f 19 >OUTPUT/tnas-tmp/"$SERIAL"-Model-Type.txt
    MODELTYPE=$(cat OUTPUT/tnas-tmp/"$SERIAL"-Model-Type.txt)

    # Backup script if no individual check exists

    if [[ ! -f "SWQC/SWQC-$MODELTYPE.sh" ]]; then
        MODELTYPE=TRUENAS-ALL
    fi

    # Executing script on remote system

    # Script is piped via stdin to SSH so it executes on the remote TrueNAS system without needing to copy it there first
    sshpass <~/3-iX-WSL-CC/SWQC/SWQC-"$MODELTYPE".sh -vp <TRUENAS_ROOT_PASSWORD> ssh -tt -oStrictHostKeyChecking=no root@"$IP" -yes

done

rm -rf OUTPUT/tnas-tmp/

exit
