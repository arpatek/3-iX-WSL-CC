#!/bin/bash
# Title         :Redfish-Disable.sh
# Description   :Script to Disable Redfish user
# Author        :Juan Garcia
# Date          :1-19-23
# Version       :1.0

cd /tmp || exit
mkdir /tmp/ix-tmp

# Grabbing serial number
dmidecode -t1 | grep -E -o -i "A1-.{0,6}" > ix-tmp/System-Serial.txt
SERIAL=$(cat ix-tmp/System-Serial.txt)

echo "==========================================================================" >> ix-tmp/LINE-Output.txt

# Replace placeholders with actual values
ipmi=YOUR_IPMI_IP
pw='YOUR_IPMI_PASSWORD'

# Disable Redfish user
curl -v -k -u "admin:${pw}" \
    --request PATCH "https://${ipmi}/redfish/v1/AccountService/Accounts/1" \
    --header 'If-None-Match: W/"WHITENOISE"' \
    --header 'Content-Type: application/json' \
    --data-raw '{"Enabled": false}' > ix-tmp/Redfish-Disable.txt

echo "==========================================================================" >> ix-tmp/LINE-Output.txt

# Disable Redfish user and append output to Redfish-Disable.txt
curl -v -k -u "admin:${pw}" \
    --request PATCH "https://${ipmi}/redfish/v1/AccountService/Accounts/1" \
    --header 'If-None-Match: W/"WHITENOISE"' \
    --header 'Content-Type: application/json' \
    --data-raw '{"Enabled": false}' &>> ix-tmp/Redfish-Disable.txt

echo "==========================================================================" >> ix-tmp/LINE-Output.txt

# Check Redfish user status and write to Redfish-Check.txt
curl -v -s -k -u "admin:${pw}" --request GET "https://${ipmi}/redfish/v1/AccountService/Accounts/1" | jq .Enabled > ix-tmp/Redfish-Check.txt

echo "==========================================================================" >> ix-tmp/LINE-Output.txt

# Check Redfish user status and append output to Redfish-Check.txt
curl -v -s -k -u "admin:${pw}" --request GET "https://${ipmi}/redfish/v1/AccountService/Accounts/1" | jq .Enabled &>> ix-tmp/Redfish-Check.txt

echo "==========================================================================" >> ix-tmp/LINE-Output.txt

# Compress output file
tar -czvf "$SERIAL-Redfish-Disable.tar.gz" ix-tmp/

echo "==========================================================================" >> ix-tmp/LINE-Output.txt

# Setting up for mounting SJ Storage
mkdir /mnt/sj-storage
mount -t cifs -o vers=3,username=YOUR_USERNAME,password=YOUR_PASSWORD '//YOUR_SMB_HOST/sj-storage/' /mnt/sj-storage/
cat /mnt/sj-storage/swqc-output/smbconnection-verified.txt >> ix-tmp/swqc-output.txt
cat /mnt/sj-storage/swqc-output/smbconnection-verified.txt > ix-tmp/smb-verified.txt
echo "SJ Storage mounted"

echo "==========================================================================" >> ix-tmp/LINE-Output.txt

# Copy tar.gz file to swqc-output on SJ Storage
cd /tmp || return
cp -- *.tar.gz /mnt/sj-storage/swqc-output/
echo "Finished copying tar.gz file to swqc-output on SJ Storage"

echo "==========================================================================" >> ix-tmp/LINE-Output.txt

# Clean up
rm -rf ix-tmp/
rm -rf -- *.tar.gz ix-tmp/

exit
