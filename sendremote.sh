#!/bin/bash

REPORTS=(
    "/tmp/long_software_Format.txt"
    "/tmp/Long_Hardware_Format.txt"
    "/tmp/short_SOFTWARE_Format.txt"
    "/tmp/Short_Hardware_Format.txt"
)

# Colors
BLUE='\033[38;5;39m'
GREEN='\033[0;32m'
RED='\033[31m'
NC='\033[0m'

echo -e "${BLUE}NSCS Remote Transfer${NC}"

read -p "Enter Target IP Address: " TARGET_IP
read -p "Enter Remote Username: " SSH_USER
read -p "Target Port: " TARGET_PORT
TARGET_PORT=${TARGET_PORT:-2222} #because we've switched the port to 2222

read -p "Is the target Windows? (y/n): " IS_WINDOWS
if [[ "$IS_WINDOWS" == "y" || "$IS_WINDOWS" == "Y" ]]; then
    read -p "Enter Windows Path (e.g: C:\Users\Public): " REMOTE_DIR
else
    read -p "Enter Linux Directory[/tmp]:" REMOTE_DIR
    REMOTE_DIR=${REMOTE_DIR:-/tmp}
fi

echo -e "\nConnecting to $TARGET_IP on port $TARGET_PORT..."

for report in "${REPORTS[@]}"; do
    if [[ -f "$report" ]]; then
        scp -P "$TARGET_PORT" "$report" "$SSH_USER@$TARGET_IP:\"$REMOTE_DIR\""
        if [[ $? -eq 0 ]]; then
            echo -e "${GREEN}Sent:${NC} $(basename "$report")"
        else
            echo -e "${RED}Failed to send:${NC} $(basename "$report")"
        fi
    else
        echo -e "${RED}File not found:${NC} $report"
    fi
done
