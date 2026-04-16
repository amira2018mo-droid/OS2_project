#!/bin/bash

REMOTE_IP="10.195.95.36" #the address of my machine
REMOTE_USER="sandy" #the username of the remote machine
LOCAL_STORE="/var/log/sys_audit/remote_reports"

mkdir -p "$LOCAL_STORE" #make directory with parent subdirectories if needed

echo -e "\033[38;5;39m[*] Connecting to $REMOTE_IP for audit... \033[0m"

# Execute the remote script and capture output locally
# This assumes hardshort.sh is in the remote user's home folder
ssh "$REMOTE_USER@$REMOTE_IP" "sudo ~/hardshort.sh" > "$LOCAL_STORE/remote_hw_$(date +%F).txt"

# Verify success
if [ $? -eq 0 ]; then
    echo -e "\033[38;5;206m[SUCCESS] Remote report saved to $LOCAL_STORE\033[0m"
else
    echo -e "\033[31m[ERROR] Connection failed. Check SSH keys.\033[0m"
fi
