#!/bin/bash

######################################
#    Script Name: Boot-BIOS.sh       #
#    Author: 3EYEDGOD                #
#    Updated: 06/20/2023                #
#    Version: 2.0                    #
######################################

######################################
#            Troubleshooting          #
######################################
# If the script is not executing, make sure it has execute permissions.
# You can set the permissions using the following command:
# chmod +x Boot-BIOS.sh

# If the dialog utility is not installed, install it using the package manager specific to your operating system.
# For example, on Ubuntu, you can install it with:
# sudo apt-get install dialog

######################################
#            Main Script              #
######################################

KEY_FILE=~/3-iX-WSL-CC/SCRIPTS/KEY.txt

# Prompt user to confirm if they want to set the bootflag to force BIOS
dialog --yesno "Do you want to set the bootflag to force BIOS?" 7 30
response=$?

if [ $response -eq 0 ]; then
    while read -r IPMIIP IPMIUSER IPMIPASSWORD; do
        # Set the bootflag to force BIOS using ipmitool (quiet mode)
        ipmitool -I lanplus -H "$IPMIIP" -U "$IPMIUSER" -P "$IPMIPASSWORD" chassis bootparam set bootflag force_bios &>/dev/null
        ipmitool -H "$IPMIIP" -U "$IPMIUSER" -P "$IPMIPASSWORD" chassis bootparam set bootflag force_bios &>/dev/null
    done < "$KEY_FILE"
fi

# Prompt user to confirm if they want to reboot the system
dialog --yesno "Do you want to reboot the system?" 7 30
reboot_response=$?

if [ $reboot_response -eq 0 ]; then
    while read -r IPMIIP IPMIUSER IPMIPASSWORD; do
        # Reboot the system using ipmitool (quiet mode)
        ipmitool -I lanplus -H "$IPMIIP" -U "$IPMIUSER" -P "$IPMIPASSWORD" power reset &>/dev/null
    done < "$KEY_FILE"
fi

# Prompt user to confirm if they want to reboot the system
# dialog --yesno "Do you want to Power off the system?" 7 30
# reboot_response=$?

# if [ $reboot_response -eq 0 ]; then
#     while read -r IPMIIP IPMIUSER IPMIPASSWORD; do
#         # Reboot the system using ipmitool (quiet mode)
#         ipmitool -I lanplus -H "$IPMIIP" -U "$IPMIUSER" -P "$IPMIPASSWORD" power off &>/dev/null
#     done < "$KEY_FILE"
# fi

dialog --msgbox "Process completed successfully!" 7 30

