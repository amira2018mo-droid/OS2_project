#!/bin/bash

#strict mode : exit on error, undefined vars, or pipe failures
set -euo pipefail

#1.CONFIGURATION & PATHS
OUT="/tmp/long_software_Format.txt"
LOG_FILE="/var/log/software_audit.log"
ERROR_LOG="/var/log/software_audit_errors.log"

#Color Palette
PINK='\033[38;5;206m'
PURPLE='\033[38;5;129m'
BLUE='\033[38;5;39m'
RED='\033[31m'
NC='\033[0m' # No Color

#ROOT PRIVILEGE CHECK
if [[ $EUID -ne 0 ]]; then #EUID:means effective user ID
   echo -e "${RED}[!] Error: This script must be run as root.${NC}"
   echo -e "${BLUE}Please use: sudo ./softfull.sh${NC}"
   exit 1
fi

#INITIALIZE FILES & TRAPS
BASELINE="/root/authorized_baseline.txt"
CURRENT_SCAN="/tmp/current_software_scan.txt"

#Initialize files
: > "$OUT"
touch "$LOG_FILE" "$ERROR_LOG"

#Setup Traps
trap 'echo "[$(date)] ERROR: Script failed at line $LINENO" >> "$ERROR_LOG"' ERR
trap 'echo "[$(date)] Audit session ended with status $?" >> "$LOG_FILE"' EXIT

#UNAUTHORIZED PROGRAM DETECTION
# We do this BEFORE the main report block starts
echo -e "\n${PINK}[ SECURITY: UNAUTHORIZED PROGRAM CHECK ]${NC}"
#the normal case
if [ ! -f "$BASELINE" ]; then #Added space after  and before 
    echo -e "${RED}[!] Baseline not found at $BASELINE!! Run the baseline command in terminal first.${NC}"
else
#look for what is new
    dpkg-query -W -f='${binary:Package}\n' | sort > "$CURRENT_SCAN"
    UNAUTHORIZED=$(comm -13 "$BASELINE" "$CURRENT_SCAN")
    
    if [ -n "$UNAUTHORIZED" ]; then
#we found some differences
        echo -e "${RED}[!] ALERT: Unauthorized programs detected:${NC}"
        echo "$UNAUTHORIZED" | sed 's/^/  - /'
        echo "[$(date)] SECURITY INCIDENT: Unauthorized software found: $UNAUTHORIZED" >> "$LOG_FILE"
    else
#everything matches
        echo -e "${BLUE}No unauthorized software detected. System integrity confirmed.${NC}"
    fi
fi


#Setup log rotation for system persistence
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
#head
{
    echo -e "${PURPLE}==========================================================${NC}"
    echo -e "${PURPLE}       NATIONAL SCHOOL OF CYBERSECURITY (NSCS)            ${NC}"
    echo -e "${PURPLE}           SOFTWARE AUDIT & MONITORING REPORT               ${NC}"
    echo -e "${PURPLE}==========================================================${NC}"
    echo -e "${BLUE}Generated on:${NC} $(date)"
    echo -e "${BLUE}Virtual Machine Name:${NC}  $(hostname)"
    echo -e "${PURPLE}----------------------------------------------------------${NC}"

#SYSTEM IDENTIFICATION
echo -e "\n${PINK}[ SYSTEM IDENTIFICATION ]${NC}"
echo -e "OS Name: $(grep 'PRETTY_NAME' /etc/os-release | cut -d'"' -f2)"
echo -e "Kernel: $(uname -smrv)"
echo -ne "Distribution: "
lsb_release -ds 2>/dev/null || echo "LSB info not found"

#SOFTWARE & PACKAGES
echo -e "\n${PINK}[ SOFTWARE INVENTORY ]${NC}"
echo -e "Total Packages (dpkg): $(dpkg-query -l | wc -l)"
echo -ne "GCC: " && gcc --version | head -n 1 2>/dev/null || echo "Not Found"
echo -ne "Python3: " && python3 --version 2>/dev/null || echo "Not Found"
echo -ne "OpenSSL: " && openssl version 2>/dev/null || echo "Not Found"
# /dev/null acts as a garbage
#REPOSITORY AUDIT
echo -e "\n${PINK}[ REPOSITORY & SOURCE AUDIT ]${NC}"
echo -e "${BLUE}Active Software Repositories:${NC}"
grep -v '^#' /etc/apt/sources.list /etc/apt/sources.list.d/* 2>/dev/null | awk '{print $2}' | sort -u | head -n 10

#USERS & ENVIRONMENT
echo -e "\n${PINK}[ USERS & ENVIRONMENT ]${NC}"
echo -e "${BLUE} Active Sessions:${NC}"
who
echo -e "\n${BLUE}Login History (Last 5):${NC}"
last -n 5

#SCHEDULED TASKS OR CRON JOBS
echo -e "\n${PINK}[ SCHEDULED SOFTWARE TASKS ]${NC}"
echo -e "${BLUE}System-wide Cron Jobs:${NC}"
found=false
for file in /etc/cron.*; do
 if [[ -e "$file" ]]; then
 ls -l "$file"
 found=true
 fi
 done
 if [[ "$found" = false ]]; then
 echo "No standard cron jobs found."
fi

#PERFORMANCE & HEALTH
echo -e "\n${PINK}[ UPTIME & HEALTH ]${NC}"
echo -e "Current Uptime: $(uptime -p)"
echo -e "\n${BLUE}Disk Usage (Physical):${NC}"
df -h | grep '^/'

#KERNEL MODULES
echo -e "\n${PINK}[ KERNEL SOFTWARE MODULES ]${NC}"
echo -e "${BLUE}Loaded Modules (Network/Security focus):${NC}"
lsmod | grep -E "net|nf_|xt_|crypto" | head -n 10 || echo "No specific modules detected."

#PROCESSES & SERVICES
echo -e "\n${PINK}[ PROCESSES & SERVICES ]${NC}"
echo -e "${BLUE}Top 5 CPU Consumers:${NC}"
ps -eo comm,pid,%cpu --sort=-%cpu | head -n 6
    
echo -e "\n${BLUE}Failed Services:${NC}"
systemctl --failed --no-pager | grep -v "0 loaded units" || echo "No failed services."

#LIBRARY & SYMLINK INTEGRITY
echo -e "\n${PINK}[ SOFTWARE LIBRARY INTEGRITY ]${NC}"
echo -e "${BLUE}Checking for Broken Symbolic Links in /usr/lib:${NC}"
find /usr/lib -xtype l -maxdepth 2 2>/dev/null | head -n 5 || echo "No broken links found."

#SECURITY & NETWORK
echo -e "\n${PINK}[ SECURITY & NETWORK ]${NC}"
echo -e "${BLUE}Firewall Status:${NC}"
if ufw status | grep -q "inactive"; then
    echo "UFW is disabled."
else
    ufw status
fi
#ufw:stands for the firewall in Linux
#SSH Audit
echo -e "\n${BLUE}SSH Server Configuration:${NC}"
grep -E "^(Port|PermitRootLogin|PasswordAuthentication)" /etc/ssh/sshd_config 2>/dev/null || echo "SSH config not readable."

echo -e "\n${BLUE}Network Listening Ports:${NC}"
ss -tuln | grep LISTEN || echo "No listening ports found."

#PRIVILEGED BINARIES (SUID/SGID)
echo -e "\n${PINK}[ PRIVILEGED BINARIES AUDIT ]${NC}"
echo -e "${BLUE}Files with SUID bit (Top 10):${NC}"
find /usr/bin /usr/sbin -perm -4000 -type f 2>/dev/null | head -n 10

#SOFTWARE UPDATES
echo -e "\n${PINK}[ SOFTWARE UPDATES ]${NC}"
echo -e "${BLUE}Upgradable Packages (Top 10):${NC}"
apt list --upgradable 2>/dev/null | grep -v "Listing..." | head -n 10 || echo "All packages up to date."

#footer
echo -e "\n${PURPLE}==========================================================${NC}"
echo -e "${PINK}   Audit Completed,it is saved to: ${BLUE}$OUT${NC}"
    echo -e "${PURPLE}==========================================================${NC}"

} | tee -a "$OUT" "$LOG_FILE"
# tee -a: output to terminal + redirection to log file

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
