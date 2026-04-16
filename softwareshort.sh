#!/bin/bash

#strict mode : exit on error, undefined vars, or pipe failures
set -euo pipefail

#Configuration & Paths
REPORT_FILE="/tmp/short_SOFTWARE_Format.txt"
LOG_FILE="/var/log/software_audit.log"
ERROR_LOG_FILE="/var/log/software_audit_errors.log"

#Color Palette 
PINK='\033[38;5;206m'
PURPLE='\033[38;5;129m'
BLUE='\033[38;5;39m'
RED='\033[31m'
NC='\033[0m' # No Color

#Root Privilege Check
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}Please run as root (sudo).${NC}"
   exit 1
fi

#Initialize Files
# We use absolute paths and ensure the error log variable is defined
: > "$REPORT_FILE"
touch "$LOG_FILE" "$ERROR_LOG_FILE"

#Fix Logrotate Block
if [ ! -f /etc/logrotate.d/system_report ]; then
    cat <<EOF > /etc/logrotate.d/system_report
/var/log/software_audit.log {
    daily
    rotate 7
    compress
    missingok
    notifempty
}
EOF
fi

# 6. Logging & Traps
echo "Script started at $(date)" >> "$LOG_FILE"
trap 'echo "[$(date)] ERROR: script failed at line $LINENO" >> "$ERROR_LOG_FILE"' ERR
trap 'echo "[$(date)] Script completed with exit code $?" >> "$LOG_FILE"' EXIT


# We use { } | tee to send everything to the screen AND files simultaneously
{
#head

    echo -e "${PURPLE} ========================================================== ${NC}"
    echo -e "${PURPLE}        NATIONAL SCHOOL OF CYBERSECURITY (NSCS)  ${NC} "
    echo -e "${PURPLE}          Software Audit & Monitoring Report       ${NC}"
    echo -e "${PURPLE} ==========================================================${NC} " 
    echo -e "${BLUE}Generated on:  $(date)${NC} " 
    echo -e "${BLUE}Virtual machine name: $(hostname)${NC}" 
    echo -e "${PURPLE} ===== Hardware Information (Short Format) ===== ${NC}" 

#OS & Kernel Information 
#\n means a new line
echo -e "\n${PINK}- OS & Kernel Information${NC}" 
OS_NAME=$(grep 'PRETTY_NAME' /etc/os-release | cut -d'"' -f2)
echo -e "${BLUE}OS:${NC} $OS_NAME"
echo -e "${BLUE}Kernel:${NC} $(uname -r)"
echo -e "${BLUE}Architecture:${NC} $(uname -m)"

#Package Count
echo -e "\n${PINK}- Software Inventory${NC}"
PKG_COUNT=$(dpkg-query -l | wc -l)
echo -e "${BLUE}Total Installed Packages:${NC} $PKG_COUNT"

#User Activity 
echo -e "\n${PINK}- Logged-in Users${NC}"
who

#Services & Processes 
echo -e "\n${PINK}- Services & Processes${NC}"
echo -e "${BLUE}Top 3 Running Services:${NC}"
systemctl list-units --type=service --state=running --no-pager | grep '.service' | head -n 3
    
echo -e "\n${BLUE}Top 5 Active Processes (by CPU):${NC}"
ps -eo comm,%cpu --sort=-%cpu | head -n 6

#Network Audit
echo -e "\n${PINK}- Network Audit (Open Ports)${NC}" 
# Use ss -tuln for listening ports
OPEN_PORTS=$(ss -tuln | grep LISTEN | awk '{print $5}' | cut -d':' -f2 | sort -u | xargs)
echo -e "${BLUE}Listening Ports:${NC} $OPEN_PORTS"

echo -e "\n${PURPLE}------------------------------------------${NC}"
echo -e "${PINK}Report saved to ${BLUE}$REPORT_FILE${NC}"

} | tee -a "$REPORT_FILE" "$LOG_FILE"

FILE_TO_SEND="$REPORT_FILE"

#OPTIONAL EMAIL EXPORT 
echo -e "\n${PINK}[EMAIL EXPORT]${NC}"
echo -ne "${PURPLE}Do you want to send this report via email? (y/n): ${NC}"
read -r choice

if [[ "$choice" == "y" || "$choice" == "Y" ]]; then
    echo -e "${PURPLE}Enter your name:${NC}"
    read -r name

    echo -e "${PURPLE}Enter your email address:${NC}"
    read -r user_email

    # Send the email using the report variable defined earlier in the script
    echo "Hello $name, here is the system audit report from $(hostname)." | mail -s "System Audit - $(hostname)" -A "$FILE_TO_SEND" "$user_email"

    echo -e "${BLUE}Done! Report sent to $user_email.${NC}"
else
    echo -e "${BLUE}Skipping email export. Report remains saved at $FILE_TO_SEND.${NC}"
fi
