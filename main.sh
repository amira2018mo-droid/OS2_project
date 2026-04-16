#!/bin/bash

# Color Palette
PINK='\033[38;5;206m'
PURPLE='\033[38;5;129m'
BLUE='\033[38;5;39m'
RED='\033[31m'
NC='\033[0m' # No Color

# Root Privilege Check
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}[!] Error: Please run this menu as root (sudo).${NC}"
   exit 1
fi

while true; do
    clear
    echo -e "${PURPLE}==========================================================${NC}"
    echo -e "${PURPLE}       NATIONAL SCHOOL OF CYBERSECURITY (NSCS)            ${NC}"
    echo -e "${PURPLE}             SYSTEM AUDIT MASTER CONTROL                  ${NC}"
    echo -e "${PURPLE}==========================================================${NC}"
    echo -e "${BLUE}  1)${NC} Software Audit - ${PINK}Short Format${NC}"
    echo -e "${BLUE}  2)${NC} Software Audit - ${PINK}Long Format${NC}"
    echo -e "${BLUE}  3)${NC} Hardware Audit - ${PINK}Short Format${NC}"
    echo -e "${BLUE}  4)${NC} Hardware Audit - ${PINK}Long Format${NC}"
    echo -e "${BLUE}  5)${NC} ${RED}Exit Security Terminal${NC}"
    echo -e "${PURPLE}==========================================================${NC}"
    echo -ne "${BLUE}Select an option [1-5]: ${NC}"
    read -r choice

    case $choice in
        1)
            echo -e "\n${BLUE}[*] Launching Software Short Audit...${NC}"
            ./softwareshort.sh
            echo -e "\n${PINK}Press Enter to return to menu...${NC}"
            read -r
            ;;
        2)
            echo -e "\n${BLUE}[*] Launching Software Full Audit...${NC}"
            ./softwarefull.sh
            echo -e "\n${PINK}Press Enter to return to menu...${NC}"
            read -r
            ;;
        3)
            echo -e "\n${BLUE}[*] Launching Hardware Short Audit...${NC}"
            ./hardshort.sh
            echo -e "\n${PINK}Press Enter to return to menu...${NC}"
            read -r
            ;;
        4)
            echo -e "\n${BLUE}[*] Launching Hardware Long Audit...${NC}"
            ./hardlong.sh
            echo -e "\n${PINK}Press Enter to return to menu...${NC}"
            read -r
            ;;
        5)
            echo -e "\n${PURPLE}Terminating Session. Goodbye!${NC}"
            exit 0
            ;;
        *)
            echo -e "\n${RED}[!] Invalid choice. Please select 1-5.${NC}"
            sleep 2
            ;;
    esac
done
