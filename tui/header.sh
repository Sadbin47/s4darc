#!/bin/sh
# s4darc - Header & System Info Module
# Displays the gradient ASCII art header and system information

# Display header with gradient effect
show_header() {
    clear
    printf "\n"
    printf "    %b███████╗  ██╗  ██╗  ██████╗  ██╗   ██╗ ████████╗ ██╗ ██╗%b\n" "${GRAD1}" "${RC}"
    printf "    %b██╔════╝  ██║  ██║  ██╔══██╗ ██║   ██║ ╚══██╔══╝ ██║ ██║%b\n" "${GRAD2}" "${RC}"
    printf "    %b███████╗  ███████║  ██║  ██║ ██║   ██║    ██║    ██║ ██║%b\n" "${GRAD3}" "${RC}"
    printf "    %b╚════██║  ╚════██║  ██║  ██║ ██║   ██║    ██║    ██║ ██║%b\n" "${GRAD4}" "${RC}"
    printf "    %b███████║       ██║  ██████╔╝ ╚██████╔╝    ██║    ██║ ██████╗%b\n" "${GRAD5}" "${RC}"
    printf "    %b╚══════╝       ╚═╝  ╚═════╝   ╚═════╝     ╚═╝    ╚═╝ ╚═════╝%b\n" "${GRAD6}" "${RC}"
    printf "\n"
    printf "    %bArch Linux Installer v1.0%b\n" "${DIM}" "${RC}"
    printf "\n"
}

# Show system information
show_system_info() {
    show_header

    printf "  %b╭───────────────────────────────────────────╮%b\n" "${CYAN}" "${RC}"
    printf "  %b│%b  %bSystem Information%b                       %b│%b\n" "${CYAN}" "${RC}" "${BOLD}${WHITE}" "${RC}" "${CYAN}" "${RC}"
    printf "  %b╰───────────────────────────────────────────╯%b\n" "${CYAN}" "${RC}"
    printf "\n"

    # Boot mode
    if [ -d /sys/firmware/efi ]; then
        printf "    %b󰍛%b  Boot Mode      %b│%b  %b● UEFI%b\n" "${PURPLE}" "${RC}" "${DIM}" "${RC}" "${GREEN}${BOLD}" "${RC}"
        IS_UEFI=1
    else
        printf "    %b󰍛%b  Boot Mode      %b│%b  %b● BIOS (Legacy)%b\n" "${PURPLE}" "${RC}" "${DIM}" "${RC}" "${YELLOW}${BOLD}" "${RC}"
        IS_UEFI=0
    fi

    # Internet check
    if ping -c 1 -W 3 1.1.1.1 >/dev/null 2>&1 || ping -c 1 -W 3 8.8.8.8 >/dev/null 2>&1; then
        printf "    %b󰖩%b  Internet       %b│%b  %b● Connected%b\n" "${PURPLE}" "${RC}" "${DIM}" "${RC}" "${GREEN}${BOLD}" "${RC}"
    else
        printf "    %b󰖪%b  Internet       %b│%b  %b● Not Connected%b\n" "${PURPLE}" "${RC}" "${DIM}" "${RC}" "${RED}${BOLD}" "${RC}"
    fi

    # CPU
    CPU=$(grep -m1 'model name' /proc/cpuinfo | cut -d: -f2 | xargs | cut -c1-30)
    printf "    %b󰻠%b  CPU            %b│%b  %b%s%b\n" "${PURPLE}" "${RC}" "${DIM}" "${RC}" "${WHITE}" "$CPU" "${RC}"

    # RAM
    RAM=$(awk '/MemTotal/ {printf "%.1f GB", $2/1024/1024}' /proc/meminfo)
    printf "    %b󰍛%b  RAM            %b│%b  %b%s%b\n" "${PURPLE}" "${RC}" "${DIM}" "${RC}" "${WHITE}" "$RAM" "${RC}"

    # Architecture
    ARCH=$(uname -m)
    printf "    %b󰘚%b  Architecture   %b│%b  %b%s%b\n" "${PURPLE}" "${RC}" "${DIM}" "${RC}" "${WHITE}" "$ARCH" "${RC}"

    printf "\n"
    draw_line 50
    printf "\n"
}
