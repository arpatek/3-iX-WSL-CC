#!/bin/bash

# Define file paths and extensions
OUTPUT_DIR="OUTPUT"
TMP_DIR="$OUTPUT_DIR/pbs-tmp"
KEY_FILE="SCRIPTS/KEY.txt"
OUTPUT_FILE="$TMP_DIR/OUTPUT.txt"
PBS_OUT_FILE="$TMP_DIR/PBS-OUT.txt"

# Clean up previous output directory
rm -rf "$OUTPUT_DIR/PBS-CHECK"
mkdir -p "$TMP_DIR"

# Read serial numbers from KEY.txt
while IFS= read -r serial_number; do
  echo "==========================================================================" >> "$TMP_DIR/Line-Output.txt"

  # Grabbing Burn-In information from PBS logs
  pbs_directory=$(lynx --dump "https://<PBS_ARCHIVE_HOST>/pbsv4/logs/$serial_number/" | tail -1 | cut -d "/" -f7)
  if [[ -n $pbs_directory ]]; then
    echo "$pbs_directory" > "$TMP_DIR/$serial_number-DIR-Check.txt"
    curl "https://<PBS_ARCHIVE_HOST>/pbsv4/logs/$serial_number/$pbs_directory/ipmi_summary.txt" -o "$TMP_DIR/$serial_number-PBS-IPMI_Summary.txt"
  fi

  # Grabbing Passmark Log
  curl "https://<PBS_ARCHIVE_HOST>/pbsv4/logs/$serial_number/$pbs_directory/Passmark_Log.cert.htm" -o "$TMP_DIR/$serial_number-PBS-Passmark_Log.cert.htm"
  lynx --dump "$TMP_DIR/$serial_number-PBS-Passmark_Log.cert.htm" > "$TMP_DIR/$serial_number-Lynx-Cert.txt"
  lynx --dump "$TMP_DIR/$serial_number-PBS-Passmark_Log.cert.htm" | grep -F "TEST RUN" > "$TMP_DIR/$serial_number-Test-Run.txt"
  pass_fail=$(tr -s ' ' < "$TMP_DIR/$serial_number-Test-Run.txt" | cut -d ' ' -f 4 | awk '{$1=$1};1')

  # Collecting IPMI IP address
  sed -e "s/\r//g" "$TMP_DIR/$serial_number-PBS-IPMI_Summary.txt" > "$TMP_DIR/$serial_number-IPMI-Summary.txt"
  grep -Ei "IPv4 Address" < "$TMP_DIR/$serial_number-IPMI-Summary.txt" | cut -d ":" -f 2 | awk '{$1=$1};1' > "$TMP_DIR/$serial_number-IPMI-IPAdddress.txt"
  ipmi_ip=$(cat "$TMP_DIR/$serial_number-IPMI-IPAdddress.txt")

  # Collecting IPMI MAC address
  grep -Ei "BMC MAC Address" < "$TMP_DIR/$serial_number-IPMI-Summary.txt" | tr -s ' ' | cut -d " " -f5 > "$TMP_DIR/$serial_number-BMC-MAC.txt"
  ipmi_mac=$(cat "$TMP_DIR/$serial_number-BMC-MAC.txt")

  # Collecting STD info
  psql_output=$(psql -h <DB_HOST> -U <DB_USER> -d <DB_NAME> -c "select c.name, a.model, a.serial, a.rma, a.revision, a.support_number from production_part a, production_system b, production_type c, production_configuration d where a.system_id = b.id and a.type_id = c.id and b.config_name_id = d.id and b.system_serial = '$serial_number' order by b.system_serial, a.type_id, a.model, a.serial;")
  echo "$psql_output" | grep "Unique Password" | cut -d "|" -f 3 | xargs > "$TMP_DIR/$serial_number-IPMI-Password.txt"
  ipmi_password=$(cat "$TMP_DIR/$serial_number-IPMI-Password.txt")

  # Getting motherboard manufacturer info
  motherboard_manufacturer=$(lynx --dump "$TMP_DIR/$serial_number-PBS-Passmark_Log.cert.htm" | grep -F "Motherboard manufacturer" | head -n1 | xargs | cut -d " " -f 3)

  # Collecting test duration
  test_duration=$(lynx --dump "$TMP_DIR/$serial_number-PBS-Passmark_Log.cert.htm" | grep -F "Test Duration" | awk '{$1=$1};1')

  echo "$serial_number,$pass_fail,$test_duration,$ipmi_ip,$ipmi_mac,$ipmi_password,$motherboard_manufacturer" >> "$OUTPUT_FILE"

done < "$KEY_FILE"

# Format the output file
column -t -s "," -o " " "$OUTPUT_FILE" > "$PBS_OUT_FILE"

# Clear the screen and display the output
clear
dialog --textbox "$PBS_OUT_FILE" 0 0

# Move the temporary directory to the final output directory
mv "$TMP_DIR" "$OUTPUT_DIR/PBS-CHECK"


