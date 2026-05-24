#!/bin/sh
# ═══════════════════════════════════════════════════════════════
#  s4darc — Arch Linux Installer
# ═══════════════════════════════════════════════════════════════

set -e

# ─────────────────────────────────────────────────────────────
#  Resolve script directory & source modules
# ─────────────────────────────────────────────────────────────

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

if [ ! -f "$SCRIPT_DIR/scripts/common.sh" ]; then
    if [ -f /root/s4darc/scripts/common.sh ] && [ -f /root/s4darc/s4darc.sh ]; then
        exec /root/s4darc/s4darc.sh "$@"
    fi

    if ! command -v curl >/dev/null 2>&1; then
        printf '%s\n' "Error: curl is required to bootstrap s4darc."
        exit 1
    fi

    curl -fsSL https://raw.githubusercontent.com/Sadbin47/s4darc/main/install.sh | sh
    exit $?
fi

. "$SCRIPT_DIR/scripts/common.sh"

# TUI modules
. "$SCRIPT_DIR/tui/header.sh"       # show_header(), show_system_info()
. "$SCRIPT_DIR/tui/disk.sh"         # select_disk()
. "$SCRIPT_DIR/tui/kernel.sh"       # select_kernel(), select_kernel_bootloader(), resolve_kernel_name()
. "$SCRIPT_DIR/tui/system.sh"       # configure_system(), select_timezone(), select_locale(), select_keymap()
. "$SCRIPT_DIR/tui/users.sh"        # setup_users()
. "$SCRIPT_DIR/tui/summary.sh"      # show_summary()
. "$SCRIPT_DIR/tui/install.sh"      # run_installation()

# ─────────────────────────────────────────────────────────────
#  Default configuration
# ─────────────────────────────────────────────────────────────

TARGET_DISK=""
HOSTNAME="archlinux"
TIMEZONE="UTC"
LOCALE="en_US.UTF-8"
KEYMAP="us"
ROOT_PASSWORD=""
USERNAME=""
USER_PASSWORD=""
BOOTLOADER="grub"
FILESYSTEM="ext4"
KERNEL="linux"

# ─────────────────────────────────────────────────────────────
#  Main menu
# ─────────────────────────────────────────────────────────────

main_menu() {
    while true; do
        show_header
        show_system_info

        printf "  %b╭───────────────────────────────────────────╮%b\n" "${PURPLE}" "${RC}"
        printf "  %b│%b  %bMain Menu%b                                %b│%b\n" "${PURPLE}" "${RC}" "${BOLD}${WHITE}" "${RC}" "${PURPLE}" "${RC}"
        printf "  %b╰───────────────────────────────────────────╯%b\n" "${PURPLE}" "${RC}"
        printf "\n"
        printf "    %b1%b  %b󰚰%b  %bStart Installation%b\n" "${CYAN}${BOLD}" "${RC}" "${GREEN}" "${RC}" "${WHITE}" "${RC}"
        printf "    %b2%b  %b󰆍%b  %bOpen Shell%b\n" "${CYAN}${BOLD}" "${RC}" "${YELLOW}" "${RC}" "${WHITE}" "${RC}"
        printf "    %b0%b  %b󰗼%b  %bExit%b\n" "${RED}${BOLD}" "${RC}" "${RED}" "${RC}" "${DIM}" "${RC}"
        printf "\n"
        draw_line 50
        printf "  %bSelect option%b: " "${WHITE}" "${RC}"
        read -r choice

        case "$choice" in
            1)
                if select_disk; then
                    select_kernel_bootloader
                    configure_system
                    setup_users
                    if show_summary; then
                        run_installation
                        exit 0
                    fi
                fi
                ;;
            2)
                printf "\n"
                info "Type 'exit' to return to installer."
                printf "\n"
                /bin/sh
                ;;
            0)
                printf "\n"
                info "Exiting..."
                printf "\n"
                exit 0
                ;;
        esac
    done
}

# ─────────────────────────────────────────────────────────────
#  Entry point
# ─────────────────────────────────────────────────────────────

main() {
    # Check if running as root
    if [ "$(id -u)" -ne 0 ]; then
        printf "\n"
        printf "  %b╭─────────────────────────────────────────────╮%b\n" "${RED}" "${RC}"
        printf "  %b│%b  %b✗  Error: This script must be run as root%b  %b│%b\n" "${RED}" "${RC}" "${BOLD}${WHITE}" "${RC}" "${RED}" "${RC}"
        printf "  %b╰─────────────────────────────────────────────╯%b\n" "${RED}" "${RC}"
        printf "\n"
        exit 1
    fi

    exec < /dev/tty

    main_menu
}

main "$@"
