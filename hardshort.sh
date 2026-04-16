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
REPORT_FILE="/tmp/Short_Hardware_Format.txt"
LOG_FILE="/var/log/system_report.log"
ERROR_LOG_FILE="/var/log/hardware_audit_errors.log"

# Initialize files
: > "$REPORT_FILE"
touch "$LOG_FILE" "$ERROR_LOG_FILE"

# Logrotate block
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

# Trap errors and exit
trap 'echo "[$(date)] ERROR: Script failed at line $LINENO" >> "$ERROR_LOG_FILE"' ERR
trap 'echo "[$(date)] Script completed with exit code $?" >> "$LOG_FILE"' EXIT

# Head
{
echo -e "${PURPLE} ========================================================== ${NC}"
echo -e "${PURPLE}         NATIONAL SCHOOL OF CYBERSECURITY (NSCS)   ${NC} "
echo -e "${PURPLE}          Hardware Audit & Monitoring Report       ${NC}"
echo -e "${PURPLE} ==========================================================${NC} " 
echo -e "${BLUE}Generated on:  $(date)${NC} " 
echo -e "${BLUE}Node: $(hostname)${NC}" 
echo -e "${PURPLE} ===== Hardware Information (Short Format) ===== ${NC}" 
} | tee -a "$REPORT_FILE" "$LOG_FILE"
# tee -a: output to terminal + redirection to log file

# CPU
{
echo -e "\n${PINK}CPU Information:${NC}" 
echo -e "${BLUE}Model:${NC}" 
lscpu | grep "Model name" | cut -d ':' -f2  || true
echo -e "${BLUE}Architecture:${NC}" 
uname -m   
echo -e "${BLUE}Number of cores:${NC}" 
nproc  
echo -e "${BLUE}Logical CPUs:${NC}" 
lscpu | grep "CPU(s)" || true
echo -e "${BLUE}Physical cores:${NC}" 
lscpu | grep "Core(s) per socket" || true
} | tee -a "$REPORT_FILE" "$LOG_FILE"

# GPU
{
echo -e "\n${PINK}GPU Information:${NC}" 
#check if the command lspci is installed
 if command -v lspci >/dev/null 2>&1; then
    gpu=$(lspci | grep -Ei "vga|3d|display")
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

# RAM DETAILS
{
echo -e "\n${PINK}Memory Information:${NC}"  
echo -e "${BLUE}RAM Usage (total,used,available):${NC}" 
free -h  
#check if the command dmidecode is installed
if command -v dmidecode >/dev/null; then 
echo -e "${BLUE}RAM Type & Speed:${NC}" 
dmidecode -t memory | grep -E "Type:|Speed:" || true
else
echo -e "${RED}dmidecode not installed${NC}"
fi
} | tee -a "$REPORT_FILE" "$LOG_FILE"

# DISK
{
echo -e "\n${PINK}Disk Information:${NC}" 
lsblk  -o NAME,SIZE,TYPE,ROTA,MOUNTPOINT | column -t
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
echo -e "${BLUE}IP address:${NC}"  
printf "%-12s %-20s %-40s\n" "INTERFACES" "IPv4" "IPv6"
ip -o addr show | awk '/inet / {ipv4[$2]=$4} /inet6 / {ipv6[$2]=$4} END { for (i in ipv4) printf "%-12s %-20s %-40s\n", i, ipv4[i], ipv6[i]}' 
echo -e "${BLUE}MAC addresses:${NC}" 
ip -o link show | awk '/link\/ether/ {print $2, $17}'
} | tee -a "$REPORT_FILE" "$LOG_FILE"

# USB DEVICES 
{
echo -e "\n${PINK}USB Devices:${NC}" 
#check if the command lsusb is installed
if command -v lsusb >/dev/null; then
echo -e "${BLUE}Connected devices:${NC}" 
lsusb | awk '{printf "%-10s %s\n",$6,substr($0,index($0,$7))}'
else
    echo -e "${RED}lsusb not installed${NC}"
fi
} | tee -a "$REPORT_FILE" "$LOG_FILE"

# MOTHERBOARD 
{
echo -e "\n${PINK}Motherboard Information:${NC}"
echo -e "${BLUE}Motherboard/baseboard information:${NC}"
#check if the command dmidecode is installed
if command -v dmidecode >/dev/null 2>&1; then
    dmidecode -t baseboard | grep -E "Manufacturer|Product Name|Version" || true
else
    echo "dmidecode not installed"
fi
} | tee -a "$REPORT_FILE" "$LOG_FILE"

# Footer
{
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
