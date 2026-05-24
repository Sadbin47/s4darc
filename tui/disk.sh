#!/bin/sh
# S4DArc - Disk Selection Module
# Handles disk selection, filesystem choice, and swap configuration

# Select disk
select_disk() {
    show_header

    printf "  %b╭─────────────────────────────────────────────╮%b\n" "${RED}" "${RC}"
    printf "  %b│%b %b⚠  WARNING: ALL DATA WILL BE ERASED!  %b    %b%b\n" "${RED}" "${RC}" "${BOLD}${YELLOW}${BLINK}" "${RC}" "${RED}" "${RC}"
    printf "  %b╰─────────────────────────────────────────────╯%b\n" "${RED}" "${RC}"
    printf "\n"

    printf "  %b╭─────────────────────────────────────────────╮%b\n" "${CYAN}" "${RC}"
    printf "  %b│%b %b󰋊  Available Disks%b                          %b│%b\n" "${CYAN}" "${RC}" "${BOLD}${WHITE}" "${RC}" "${CYAN}" "${RC}"
    printf "  %b╰─────────────────────────────────────────────╯%b\n" "${CYAN}" "${RC}"
    printf "\n"

    # List disks and store in array-like format
    DISK_LIST=$(lsblk -d -n -o NAME,SIZE,MODEL 2>/dev/null | grep -E '^(sd|nvme|vd|hd)' || true)

    if [ -z "$DISK_LIST" ]; then
        err "No disks found!"
        sleep 2
        return 1
    fi

    i=1
    echo "$DISK_LIST" | while IFS= read -r line; do
        name=$(echo "$line" | awk '{print $1}')
        size=$(echo "$line" | awk '{print $2}')
        model=$(echo "$line" | awk '{$1=$2=""; print $0}' | xargs | cut -c1-20)
        printf "    %b%b %d %b  %b/dev/%s%b  %b(%s)%b  %b%s%b\n" "${CYAN}${BOLD}" "󰋊" "$i" "${RC}" "${WHITE}${BOLD}" "$name" "${RC}" "${GREEN}" "$size" "${RC}" "${DIM}" "$model" "${RC}"
        i=$((i + 1))
    done

    disk_count=$(echo "$DISK_LIST" | wc -l)

    printf "\n"
    printf "    %b%b 0 %b  %bGo Back%b\n" "${YELLOW}${BOLD}" "󰁍" "${RC}" "${YELLOW}" "${RC}"
    printf "\n"

    draw_line 50
    printf "  %bSelect disk%b %b[1-%d]%b: " "${WHITE}" "${RC}" "${DIM}" "$disk_count" "${RC}"
    read -r choice

    if [ "$choice" = "0" ]; then
        return 1
    fi

    # Validate choice is a number
    if ! echo "$choice" | grep -qE '^[0-9]+$'; then
        err "Invalid selection!"
        sleep 2
        select_disk
        return
    fi

    # Get selected disk name from the list
    selected_line=$(echo "$DISK_LIST" | sed -n "${choice}p")
    disk_name=$(echo "$selected_line" | awk '{print $1}')
    TARGET_DISK="/dev/$disk_name"

    if [ -z "$disk_name" ] || [ ! -b "$TARGET_DISK" ]; then
        err "Invalid selection!"
        sleep 2
        select_disk
        return
    fi

    # Confirm
    printf "\n"
    printf "  %b╭─────────────────────────────────────────────╮%b\n" "${RED}" "${RC}"
    printf "  %b│%b %bALL DATA ON %-12s WILL BE LOST!%b     %b%b\n" "${RED}" "${RC}" "${BOLD}${WHITE}" "$TARGET_DISK" "${RC}" "${RED}" "${RC}"
    printf "  %b╰─────────────────────────────────────────────╯%b\n" "${RED}" "${RC}"
    printf "\n  %bAre you sure?%b %b[y/N]%b: " "${WHITE}" "${RC}" "${DIM}" "${RC}"
    read -r confirm
    case "$confirm" in
        [Yy]*)
            ok "Selected: $TARGET_DISK"
            export S4D_TARGET_DISK="$TARGET_DISK"
            ;;
        *)
            select_disk
            return
            ;;
    esac

    # Filesystem selection
    printf "\n"
    printf "  %b╭─────────────────────────────────────────────╮%b\n" "${CYAN}" "${RC}"
    printf "  %b│%b %b  Filesystem Selection%b                    %b%b\n" "${CYAN}" "${RC}" "${BOLD}${WHITE}" "${RC}" "${CYAN}" "${RC}"
    printf "  %b╰─────────────────────────────────────────────╯%b\n" "${CYAN}" "${RC}"
    printf "\n"
    printf "    %b󰉋%b  %bFilesystem%b %b[Default: ext4]%b\n" "${PURPLE}" "${RC}" "${WHITE}" "${RC}" "${DIM}${CYAN}" "${RC}"
    printf "\n"
    printf "      %b1%b) %bext4%b            %b(stable, recommended)%b\n" "${CYAN}${BOLD}" "${RC}" "${WHITE}" "${RC}" "${DIM}" "${RC}"
    printf "      %b2%b) %bxfs%b             %b(high performance)%b\n" "${CYAN}${BOLD}" "${RC}" "${WHITE}" "${RC}" "${DIM}" "${RC}"
    printf "\n       %b➜%b " "${CYAN}" "${RC}"
    read -r fs_choice
    case "$fs_choice" in
        2) FILESYSTEM="xfs" ;;
        *) FILESYSTEM="ext4" ;;
    esac
    export S4D_FILESYSTEM="$FILESYSTEM"
    ok "Filesystem: $FILESYSTEM"

    # Swap file configuration
    printf "\n"
    printf "  %b╭─────────────────────────────────────────────╮%b\n" "${CYAN}" "${RC}"
    printf "  %b│%b %b󰾴  Swap Configuration%b                        %b%b\n" "${CYAN}" "${RC}" "${BOLD}${WHITE}" "${RC}" "${CYAN}" "${RC}"
    printf "  %b╰─────────────────────────────────────────────╯%b\n" "${CYAN}" "${RC}"
    printf "\n"

    # Get RAM size in GB for suggestion
    RAM_GB=$(awk '/MemTotal/ {printf "%.0f", $2/1024/1024}' /proc/meminfo)
    SUGGESTED_SWAP=$((RAM_GB > 0 ? RAM_GB : 4))

    printf "    %b󰾴%b  %bEnable swap file?%b %b[Y/n]%b: " "${PURPLE}" "${RC}" "${WHITE}" "${RC}" "${DIM}" "${RC}"
    read -r enable_swap

    case "$enable_swap" in
        [Nn]*)
            SWAP_SIZE=0
            info "Swap disabled"
            ;;
        *)
            printf "\n"
            printf "    %b󰾴%b  %bSwap File Size (GB)%b %b[Default: %d GB]%b\n" "${PURPLE}" "${RC}" "${WHITE}" "${RC}" "${GREEN}${BOLD}" "$SUGGESTED_SWAP" "${RC}"
            printf "       %bBased on your RAM: %s GB%b\n" "${DIM}" "$RAM_GB" "${RC}"
            printf "       %b➜%b " "${CYAN}" "${RC}"
            read -r swap_input

            if [ -n "$swap_input" ] && echo "$swap_input" | grep -qE '^[0-9]+$'; then
                SWAP_SIZE="$swap_input"
            else
                SWAP_SIZE="$SUGGESTED_SWAP"
            fi
            ok "Swap size: ${SWAP_SIZE} GB"
            ;;
    esac
    export S4D_SWAP_SIZE="$SWAP_SIZE"

    sleep 1
}
