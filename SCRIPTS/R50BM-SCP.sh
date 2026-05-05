#!/bin/bash
# Title: R50BM-SCP.sh
# Description: Designed To Run AOC-SLG3-4E2P.sh
# Author: Juan Garcia
# Updated: 11-11-22
# Version: 1.0
#########################################################################################################

# # Grabbring serial number & ip from IP.txt

# mkdir OUTPUT/scp-tmp
# cp ~/3-iX-WSL-CC/SCRIPTS/KEY.txt OUTPUT/scp-tmp/Input.txt

# FILE=OUTPUT/scp-tmp/Input.txt
# IP=""
# exec 3<&0
# exec 0<$FILE
# while read -r LINE; do
#     IP=$(echo "$LINE" | cut -d " " -f 1)

#     # Clearing ssh key from known_hosts file

#     ssh-keygen -f "/home/$USER/.ssh/known_hosts" -R "$IP"

#     # Usin SCP to copy files to TrueNAS R50BM

#     sshpass -p <TRUENAS_ROOT_PASSWORD> scp -P22 -qo StrictHostKeyChecking=no ~/3-iX-WSL-CC/SCRIPTS/VALIDATION/R50BM/plx_eeprom root@"$IP":/var/tmp
#     sshpass -p <TRUENAS_ROOT_PASSWORD> scp -P22 -qo StrictHostKeyChecking=no ~/3-iX-WSL-CC/SCRIPTS/VALIDATION/R50BM/sm_patch2.eep root@"$IP":/var/tmp

#     # Using cat to run validation script AOC-SLG3-4E2P.sh on TrueNAS R50BM

#     cat ~/3-iX-WSL-CC/SCRIPTS/VALIDATION/R50BM/AOC-SLG3-4E2P.sh | sshpass -vp <TRUENAS_ROOT_PASSWORD> ssh -tt -oStrictHostKeyChecking=no root@"$IP" -yes 

# done

# exit


set -e

# Create directory for temporary files
tmp_dir="OUTPUT/scp-tmp"
mkdir -p "$tmp_dir"

# Copy input file
cp ~/3-iX-WSL-CC/SCRIPTS/KEY.txt "$tmp_dir/Input.txt"

# Iterate over input file
while read -r ip _; do
    # Clear SSH key from known_hosts file
    ssh-keygen -f "/home/$USER/.ssh/known_hosts" -R "$ip"

    # Use SCP to copy files to TrueNAS R50BM
    sshpass -p <TRUENAS_ROOT_PASSWORD> scp -P22 -qo StrictHostKeyChecking=no ~/3-iX-WSL-CC/SCRIPTS/VALIDATION/R50BM/{plx_eeprom,sm_patch2.eep} "root@$ip:/var/tmp"

    # Run validation script AOC-SLG3-4E2P.sh on TrueNAS R50BM
    sshpass -vp <TRUENAS_ROOT_PASSWORD> ssh -tt -oStrictHostKeyChecking=no "root@$ip" -yes < ~/3-iX-WSL-CC/SCRIPTS/VALIDATION/R50BM/AOC-SLG3-4E2P.sh
done < "$tmp_dir/Input.txt"

# Remove temporary directory
rm -rf "$tmp_dir"

exit