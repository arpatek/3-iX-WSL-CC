#!/bin/bash
#########################################################################################################
# Title: 3-iX-CC.sh
# Description: Menu For Scripts
# Author: jgarcia@ixsystems.com
# Updated: 04:11:2022
# Version: 2.0
#########################################################################################################

# Define the dialog exit status codes

: "${DIALOG_OK=0}"
: "${DIALOG_CANCEL=1}"
: "${DIALOG_HELP=2}"
: "${DIALOG_EXTRA=3}"
: "${DIALOG_ITEM_HELP=4}"
: "${DIALOG_ESC=255}"

# Purpose - Run CC-Config.sh

function CC-Config() {
	SCRIPTS/CC-Config.sh
}

# Purpose - TrueNAS-Validation.sh

function TrueNAS-Validation() {
	SCRIPTS/TrueNAS-Validation.sh
}

# Purpose - Run R50BM-SCPsh

function R50BM-SCP() {
	SCRIPTS/R50BM-SCP.sh
}

# Purpose - Run CM6-Validation.sh

function CM6-Validation() {
	SCRIPTS/CM6-Validation.sh
}

# Purpose - Run BIOS-Default.sh

function BIOS-Default() {
	SCRIPTS/BIOS-Default.sh
}

# Purpose - Run Sum-Validation.sh

function SUM-Validation() {
	SCRIPTS/SUM-Validation.sh
}

# Purpose - Run Redfish-Disable.sh

function Run-Redfish-Disable() {
	SCRIPTS/Run-Redfish-Disable.sh
}

# Purpose - Run ARM-PBS.sh

function ARM-PBS() {
	SCRIPTS/ARM-PBS.sh
}

# Purpose - Run Sensor-List.sh

function Sensor-List() {
	SCRIPTS/Sensor-List.sh
}

# Purpose - Run Logs-Only.sh

function Logs-Only() {
	SCRIPTS/Logs-Only.sh
}

# Purpose - Run VRSGN-AMD-1123US-TR4-V.08.sh

function VRSGN-AMD-1123US-TR4-V.08() {
	SCRIPTS/VRSGN-AMD-1123US-TR4-V.08.sh
}

# Purpose - Run True-Diff.sh

function True-Diff() {
	SCRIPTS/True-Diff.sh
}

# Purpose - Run Boot-BIOS.sh

function Boot-BIOS() {
	SCRIPTS/Boot-BIOS.sh
	#dialog --title "Boot-BIOS Completed" --msgbox "The Boot-BIOS script has finished running." 10 40
}

# Purpose - Run HRT-BIOS-DIFF.sh

function HRT-BIOS-DIFF() {
	SCRIPTS/HRT-BIOS-DIFF.sh
}

# Purpose - Run Liquid_Immersion_Logs.sh

function Liquid-Immersion-Logs() {
	SCRIPTS/Liquid-Immersion-Logs.sh
}

# Purpose - Run HRT-Redfish-BIOS.sh

function HRT-Redfish-BIOS() {
	SCRIPTS/HRT-Redfish-BIOS.sh
}

# Purpose - Run SEL-SDR-Diff.sh

function SEL-SDR-Diff() {
	SCRIPTS/SEL-SDR-Diff.sh
}

# Purpose - Run SEL-SDR-Diff.sh

function PBS-CHECK() {
	SCRIPTS/PBS-CHECK.sh
}

# Set infinite loop

while true; do
	exec 3>&1

	### display main menu ###

	CHOICE=$(dialog --clear --backtitle "IXSYSTEMS INC. CLIENT CONFIGURATION SCRIPTS" \
		--title "[ M A I N - M E N U ]" \
		--ok-label "SELECT" \
		--cancel-label "CANCEL" \
		--cursor-off-label \
		--help-button \
		--help-label "HELP!!" \
		--menu "CHOOSE A SCRIPT TO RUN" 0 0 0 \
		CC-Config "Grab PBS Log Info & Configure Basic Settings  [S]" \
		PBS-CHECK "Check If Systems Passed Burn-In  [S]" \
		ARM-PBS "Grab PBS Log Info For ARM Servers  [S]" \
		Logs-Only "Grab PBS Log Info Only  [S]" \
		TrueNAS-Validation "Verifies TrueNAS Configuration  (TRUENAS-ONLY)  [SG]" \
		BIOS-Default "Set BIOS To Default Settings  (SUM-KEY)  [S]" \
		SUM-Validation "Grabs System Info & Configs  (NON-TRUENAS)  (SUM-KEY)  [SIUP]" \
		R30-Redfish-Disable "Disables The Default Redfish User  [IPG]" \
		Sensor-List "Grabs SDR & Sensor Information  (NON-TRUENAS)  [SIUP]" \
		SEL-SDR-Diff "Get SEL & SDR Info & Diff It [SIUP]" \
		True-Diff "Diff '3-iX-A1-XXXXX-DIFFME.txt' For SWQC  [S]" \
		Debug-Gleaner "Glean & Diff TrueNAS Debug Files {UNDER CONSTRUCTION}" \
		VRSGN-AMD-CFG "Configuration Script For VRSGN-AMD-1123US-TR4-V.08  [S]" \
		R50BM-Flashing "Flashes R50BM W/ AOC-SLG3-4E2P.sh  (TRUENAS-ONLY)  [G]" \
		CM6-Flash "Flash CM6 NVME Drives  (TRUENAS-ONLY)  [G]" \
		Boot-BIOS "Reboot System To BIOS  [IUP]" \
		Liquid-Immersion-Logs "Grab PBS Log Info For HRT  [S]" \
		HRT-Redfish-BIOS "Export BIOS Settings W/ Redfish  [I]" \
		HRT-BIOS-DIFF "Diff BIOS Files From HRT  [S]" \
		2>&1 1>&3)

	# Button Choices

	EXIT_STATUS=$?
	exec 3>&-
	case $EXIT_STATUS in
	"$DIALOG_CANCEL")
		clear
		echo -e "[PROGRAM TERMINATED]\n"
		echo -e "[GOODBYE $USER]\n" | tr '[:lower:]' '[:upper:]'
		exit
		;;
	"$DIALOG_ESC")
		clear
		echo "[PROGRAM ABORTED!!!]" >&2
		echo "[WHY YOU QUIT?!?!]" >&2
		exit 1
		;;
	"$DIALOG_HELP")
		clear
		dialog --title "HELP" --msgbox "-- Choose a script you want to run using the UP/DOWN arrows then ENTER to select desired script.

-- Make sure KEY.txt contains the appropriate information with an extra line at the end.

-- If script is not running correctly, open up the script with a text editor and go over the troubleshooting instructions. 

LEGEND:

[S]=SYSTEM_SERIAL [G]=GUI_IP [I]=IPMI_IP [U]=IPMI_USER [P]=IPMI_PASSWORD" 0 0
		dialog --title "[3EYEDGOD]" --msgbox "jgarcia@ixsystems.com

Juan Garcia
iXsystems, Inc.
Test Technician" 0 0
		;;
	esac

	# Avaliable Choices

	case $CHOICE in
	CC-Config)
		clear
		CC-Config
		;;
	ARM-PBS)
		clear
		ARM-PBS
		;;
	TrueNAS-Validation)
		clear
		TrueNAS-Validation
		;;
	R50BM-Flashing)
		clear
		R50BM-SCP
		;;
	CM6-Flash)
		clear
		CM6-Validation
		;;
	BIOS-Default)
		clear
		BIOS-Default
		;;
	SUM-Validation)
		clear
		SUM-Validation
		;;
	R30-Redfish-Disable)
		clear
		Run-Redfish-Disable
		;;
	Sensor-List)
		clear
		Sensor-List
		;;
	Logs-Only)
		clear
		Logs-Only
		;;
	SEL-SDR-Diff)
		clear
		SEL-SDR-Diff
		;;
	VRSGN-AMD-CFG)
		clear
		VRSGN-AMD-1123US-TR4-V.08
		;;
	True-Diff)
		clear
		True-Diff
		;;
	Boot-BIOS)
		clear
		Boot-BIOS
		;;
	HRT-BIOS-DIFF)
		clear
		HRT-BIOS-DIFF
		;;
	Liquid-Immersion-Logs)
		clear
		Liquid-Immersion-Logs
		;;
	HRT-Redfish-BIOS)
		clear
		HRT-Redfish-BIOS
		;;
	PBS-CHECK)
		clear
		PBS-CHECK
		;;
	esac

done
