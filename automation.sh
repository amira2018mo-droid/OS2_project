#!/bin/bash

#Define Paths (Use absolute paths for cron)
PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
LOG_FILE="/var/log/system_report.log"

#Run the Audits
# This generates the .txt report files
sudo "$PROJECT_DIR/softfull.sh"
sudo "$PROJECT_DIR/hardlong.sh"
sudo "$PROJECT_DIR/softshort.sh"
sudo "$PROJECT_DIR/hardshort.sh"


#CPU Alert System
CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8}' )
CPU_INT=${CPU_USAGE%.*}
if (( CPU_INT > 80 )); then
    ALERT_MSG="!!High CPU Usage Alert: ${CPU_INT}% on $(hostname) at $(date)"
    echo "$ALERT_MSG" >> "$LOG_FILE"
    echo "$ALERT_MSG" | mail -s "CPU ALERT - $(hostname)" "sososoundous141@gmail.com"
fi

#Automated Email
RECIPIENT="sososoundous141@gmail.com"
NAME="ccsandy"

{
    echo "Hello $NAME,"
    echo "Attached are the automated Full and Short System Audit Reports for $(hostname)."
    echo "Generated on: $(date)"
} | mail -s "Automated Audit: $(hostname)" \
    -A "/tmp/long_software_Format.txt" \
    -A "/tmp/Long_Hardware_Format.txt" \
    -A "/tmp/short_SOFTWARE_Format.txt" \
    -A "/tmp/Short_Hardware_Format.txt" \
    "$RECIPIENT"

#Log the success
echo "[$(date)] Automated Audit (Full & Short) successfully sent to $RECIPIENT" >> "$LOG_FILE"
