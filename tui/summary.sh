#!/bin/sh
# S4DArc - Installation Summary Module
# Displays final summary before installation begins

# Show summary
show_summary() {
    show_header

    printf "  %b╭─────────────────────────────────────────────╮%b\n" "${CYAN}" "${RC}"
    printf "  %b│%b  %bInstallation Summary%b                       %b│%b\n" "${CYAN}" "${RC}" "${BOLD}${WHITE}" "${RC}" "${CYAN}" "${RC}"
    printf "  %b╰─────────────────────────────────────────────╯%b\n" "${CYAN}" "${RC}"
    printf "\n"

    # System section
    printf "    %b󰋊%b  %-18s %b%s%b\n" "${PURPLE}" "${RC}" "Target Disk" "${CYAN}${BOLD}" "$TARGET_DISK" "${RC}"
    printf "    %b󰍛%b  %-18s %b%s%b\n" "${PURPLE}" "${RC}" "Boot Mode" "${WHITE}" "$([ "$IS_UEFI" = "1" ] && echo "UEFI" || echo "BIOS")" "${RC}"
    printf "    %b󰋊%b  %-18s %b%s%b\n" "${PURPLE}" "${RC}" "Bootloader" "${WHITE}" "$BOOTLOADER" "${RC}"
    printf "    %b󰉋%b  %-18s %b%s%b\n" "${PURPLE}" "${RC}" "Filesystem" "${WHITE}" "$FILESYSTEM" "${RC}"

    # Resolve kernel display name
    KERNEL_DISPLAY=$(resolve_kernel_name "$KERNEL")
    printf "    %b󰌽%b  %-18s %b%s%b\n" "${PURPLE}" "${RC}" "Kernel" "${YELLOW}${BOLD}" "$KERNEL_DISPLAY" "${RC}"
    printf "\n"
    draw_line 47
    printf "\n"

    # Configuration section
    printf "    %b󰇄%b  %-18s %b%s%b\n" "${PURPLE}" "${RC}" "Hostname" "${WHITE}" "$HOSTNAME" "${RC}"
    printf "    %b󰥔%b  %-18s %b%s%b\n" "${PURPLE}" "${RC}" "Timezone" "${WHITE}" "$TIMEZONE" "${RC}"
    printf "    %b󰗊%b  %-18s %b%s%b\n" "${PURPLE}" "${RC}" "Locale" "${WHITE}" "$LOCALE" "${RC}"
    printf "    %b󰌌%b  %-18s %b%s%b\n" "${PURPLE}" "${RC}" "Keymap" "${WHITE}" "$KEYMAP" "${RC}"
    printf "\n"
    draw_line 47
    printf "\n"

    # Swap & user section
    if [ "$S4D_SWAP_SIZE" -gt 0 ] 2>/dev/null; then
        printf "    %b󰾴%b  %-18s %b%s%b\n" "${PURPLE}" "${RC}" "Swap File" "${WHITE}" "${S4D_SWAP_SIZE} GB" "${RC}"
    else
        printf "    %b󰾴%b  %-18s %b%s%b\n" "${PURPLE}" "${RC}" "Swap File" "${DIM}" "Disabled" "${RC}"
    fi
    printf "    %b󰌋%b  %-18s %b%s%b\n" "${PURPLE}" "${RC}" "Root Password" "${CYAN}" "********" "${RC}"
    printf "    %b󰀄%b  %-18s %b%s%b\n" "${PURPLE}" "${RC}" "Username" "${WHITE}" "${USERNAME:-"(none)"}" "${RC}"

    printf "\n"
    printf "  %b╭─────────────────────────────────────────────╮%b\n" "${RED}" "${RC}"
    printf "  %b│%b  %b⚠  WARNING: This will ERASE ALL DATA on %b   %b│%b\n" "${RED}" "${RC}" "${BOLD}${YELLOW}" "${RC}" "${RED}" "${RC}"
    printf "  %b│%b     %b%-38s%b  %b│%b\n" "${RED}" "${RC}" "${WHITE}${BOLD}" "$TARGET_DISK" "${RC}" "${RED}" "${RC}"
    printf "  %b╰─────────────────────────────────────────────╯%b\n" "${RED}" "${RC}"

    printf "\n  %bProceed with installation?%b %b[y/N]%b: " "${WHITE}${BOLD}" "${RC}" "${DIM}" "${RC}"
    read -r confirm

    case "$confirm" in
        [Yy]*) return 0 ;;
        *) return 1 ;;
    esac
}
