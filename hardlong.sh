#!/bin/bash

#strict mode : exit on error, undefined vars, or pipe failures
set -euo pipefail

# Color Palette 
PINK='\033[38;5;206m'
PURPLE='\033[38;5;129m'
BLUE='\033[38;5;39m'
NC='\033[0m' # No Color
RED='\033[31m'

# Check for root privileges
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}Please run as root (sudo).${NC}"
   exit 1
fi

# Configuration
REPORT_FILE="/tmp/Long_Hardware_Format.txt"
LOG_FILE="/var/log/system_report.log"
ERROR_LOG_FILE="/var/log/hardware_audit_errors.log"

: > "$REPORT_FILE"

# Make sure log files exist
touch "$LOG_FILE" "$ERROR_LOG_FILE"

#logrotation mechanism
if [ ! -f /etc/logrotate.d/system_report ]; then
cat <<EOF > /etc/logrotate.d/system_report
/var/log/system_report.log {
    daily
    rotate 7
    compress
    missingok
    notifempty
}
EOF
fi

# Starting the script
echo "Script started at $(date)" >> "$LOG_FILE"

# Trap errors
trap 'echo "[$(date)] ERROR: Script failed at line $LINENO" >> "$ERROR_LOG_FILE"' ERR

# Trap exit to log completion
trap 'echo "[$(date)] Script completed with exit code $?" >> "$LOG_FILE"' EXIT

#head
{
echo -e "${PURPLE} ========================================================== ${NC}"
echo -e "${PURPLE}         NATIONAL SCHOOL OF CYBERSECURITY (NSCS)   ${NC} "
echo -e "${PURPLE}           Hardware Audit & Monitoring Report       ${NC}"
echo -e "${PURPLE} ==========================================================${NC} "
echo -e "${BLUE}Generated on:  $(date)${NC} " 
echo -e "${BLUE}Node: $(hostname)${NC}"
echo -e "${PURPLE} ===== Hardware Information (Long Format) ===== ${NC}" 
} | tee -a "$REPORT_FILE" "$LOG_FILE"
# tee -a: output to terminal + redirection to log file
# CPU
{
echo -e "\n${PINK}CPU Information:${NC}" 
echo -e "${BLUE}Detailed CPU Specs:${NC}" 
lscpu 
} | tee -a "$REPORT_FILE" "$LOG_FILE"

# GPU
{
echo -e "\n${PINK}GPU Information:${NC}"
#check if the command lspci is installed 
 if command -v lspci >/dev/null 2>&1; then
    gpu=$(lspci | grep -Ei "vga|3d|display" || true)
    if [ -n "$gpu" ]; then
        echo -e "${BLUE}GPU(s):${NC}"
        echo "$gpu"
    else
        echo -e "${BLUE}GPU:${NC} Not detected"
    fi
else
    echo -e "${RED}lspci not installed${NC}"
fi
} | tee -a "$REPORT_FILE" "$LOG_FILE"

# DISK
{
echo -e "\n${PINK}Disk Information:${NC}" 
echo -e "${BLUE}Disk Devices:${NC}"
lsblk 
echo -e "${BLUE}Disk Usage:${NC}" 
df -h 
echo -e "${BLUE}Detailed disk information:${NC}"
fdisk -l 2>/dev/null 
} | tee -a "$REPORT_FILE" "$LOG_FILE"

# NETWORK INTERFACES 
{
echo -e "\n${PINK}Network Interfaces:${NC}" 
echo -e "${BLUE}Interface List:${NC}" 
ip -brief link 
} | tee -a "$REPORT_FILE" "$LOG_FILE"

# IP & MAC ADDRESSES
{
echo -e "\n${PINK}MAC & IP addresses:${NC}" 
#check if the command nmcli is installed
if command -v nmcli >/dev/null; then
echo -e "${BLUE}IP address:${NC}"
nmcli -p device show | grep -E "GENERAL.DEVICE|IP4.ADDRESS|IP6.ADDRESS" || true
echo -e "${BLUE}MAC addresses:${NC}" 
nmcli device status | awk 'NR==1{printf "%-10s %-10s %-12s %-20s\n",$1,$2,$3,"MAC"} NR>1{cmd="nmcli device show "$1" | grep HWADDR | awk \"{print \\$2}\""; cmd | getline mac; close(cmd); printf "%-10s %-10s %-12s %-20s\n",$1,$2,$3,mac}' 
else
    echo -e "${RED}nmcli not installed${NC}"
fi 
} | tee -a "$REPORT_FILE" "$LOG_FILE"

# USB DEVICES
{
echo -e "\n${PINK}USB Devices:${NC}"  
#check if the command lsusb is installed
if command -v lsusb >/dev/null; then
echo -e "${BLUE}Connected devices:${NC}"
lsusb 
else
    echo -e "${RED}lsusb not installed${NC}"
fi
} | tee -a "$REPORT_FILE" "$LOG_FILE"

# MOTHERBOARD 
{
echo -e "\n${PINK}Motherboard Information:${NC}"
#check if the command dmidecode is installed 
if command -v dmidecode >/dev/null; then
echo -e "${BLUE}Detailed motherboard/baseboard information:${NC}"
dmidecode -t baseboard 2>/dev/null || true
else
    echo -e "${RED}dmidecode not installed${NC}"
fi
} | tee -a "$REPORT_FILE" "$LOG_FILE"

# Footer
{
echo -e "\n${PURPLE}------------------------------------------${NC}"
echo -e "${PINK}Report saved to ${BLUE}$REPORT_FILE${NC}"
} | tee -a "$REPORT_FILE" "$LOG_FILE"

FILE_TO_SEND="$OUT"

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
