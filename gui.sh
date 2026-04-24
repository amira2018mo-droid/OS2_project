#!/bin/bash

#ROOT PRIVILEGE CHECK
if [[ $EUID -ne 0 ]]; then
   echo "Error: This menu must be run as root (sudo)."
   exit 1
fi

#THEME CONFIGURATION
DIAL_CONF="/tmp/theme.cfg"
cat << EOF > "$DIAL_CONF"
use_colors = ON
screen_color = (CYAN,MAGENTA,ON)
dialog_color = (BLACK,WHITE,OFF)
title_color = (MAGENTA,WHITE,ON)
border_color = (MAGENTA,WHITE,ON)
button_active_color = (WHITE,MAGENTA,ON)
button_inactive_color = (BLACK,WHITE,OFF)
tag_color = (MAGENTA,WHITE,ON)
item_color = (BLACK,WHITE,OFF)
item_selected_color = (WHITE,MAGENTA,ON)
EOF

#export to make it environment variable
export DIALOGRC="$DIAL_CONF"

#MAIN LOOP
while true; do
    CHOICE=$(dialog --clear \
                --backtitle "NSCS - NATIONAL SCHOOL OF CYBERSECURITY | OS MINI-PROJECT" \
                --title "[ AUDIT & MONITORING SYSTEM ]" \
                --menu "Select a specialized audit task:" 17 65 6 \
                1 "Software Audit (Short Format)" \
                2 "Software Audit (Full Format)" \
                3 "Hardware Audit (Short Format)" \
                4 "Hardware Audit (Full Format)" \
                5 "System Monitoring (Remote Dashboard)" \
                6 "Exit Terminal" \
                2>&1 >/dev/tty)

    case $CHOICE in
        1)
            clear
            echo "Launching Software Short Audit..."
            ./softwareshort.sh
            read -r -p "Press Enter to return to menu..."
            ;;
        2)
            clear
            echo "Launching Software Full Audit..."
            ./softwarefull.sh
            read -r -p "Press Enter to return to menu..."
            ;;
        3)
            clear
            echo "Launching Hardware Short Audit..."
            ./hardshort.sh
            read -r -p "Press Enter to return to menu..."
            ;;
        4)
            clear
            echo "Launching Hardware Long Audit..."
            ./hardlong.sh
            read -r -p "Press Enter to return to menu..."
            ;;
        5)
            clear
            echo "Accessing Remote Monitoring Dashboard..."
            ./sendremote.sh
            read -r -p "Press  Enter to return to menu..."
            ;;
        6)
            clear
            rm -f "$DIAL_CONF"
            echo "NSCS Audit System Terminated."
            exit 0
            ;;
        *)
            rm -f "$DIAL_CONF"
            exit 0
            ;;
    esac
done

