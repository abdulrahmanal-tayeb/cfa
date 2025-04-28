#!/bin/bash

paint_intro(){
    echo -e "
${MAGENTA} ▗▄▄▖▗▄▄▄▖ ▗▄▖ ${RESET}
${MAGENTA}▐▌   ▐▌   ▐▌ ▐▌${RESET}
${MAGENTA}▐▌   ▐▛▀▀▘▐▛▀▜▌${RESET}
${MAGENTA}▝▚▄▄▖▐▌   ▐▌ ▐▌${RESET}
                             
▐▘        ${BLUE}▄▖   ▗ ▄▖   ▌  ${RESET}
▜▘▛▘▛▌▛▛▌ ${BLUE}▌▌▛▛▌▜▘▌ ▛▌▛▌█▌${RESET}
▐ ▌ ▙▌▌▌▌ ${BLUE}▛▌▌▌▌▐▖▙▖▙▌▙▌▙▖${RESET}
    
    
";
}


paint_title(){
    echo -e "\n${2:-$MAGENTA}$1\n=======================================${RESET}\n";
}


paint_message(){
echo -e "${2:-$CYAN}-> $1${RESET}\n";
}