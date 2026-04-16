#!/bin/bash
# SENDING THE REPORT 
# This part handles sending the chosen file to the user's email
echo -e "\n${PINK}[EMAIL EXPORT]${NC}"

# Get user details for a personalized touch
echo -e "${PURPLE}Enter your name:${NC}"
read person_name

echo -e "${PURPLE}Enter your email address:${NC}"
read user_email

# Simple choice for which file to send
echo -e "${BLUE}Which file do you want? (1 for Short, 2 for Full):${NC}"
read file_pick

# Set the filename based on the choice
if [ "$file_pick" == "1" ]; then
    FILE_TO_SEND="short_report.txt"
else
    FILE_TO_SEND="full_audit_report.txt"
fi

# Check if file is there before trying to send
if [ -f "$FILE_TO_SEND" ]; then
    echo -e "${GREEN}Sending $FILE_TO_SEND to $user_email...${NC}"

    # -s: Subject line
    # -A: Attachment
    echo "Hello $person_name, here is the system audit report you asked for." | mail -s "System Audit - $(hostname)" -A "$FILE_TO_SEND" "$user_email"

    echo -e "${GREEN}Done! Check your inbox.${NC}"
else
    echo -e "${RED}Error: $FILE_TO_SEND not found. Run the audit again.${NC}"
fi
