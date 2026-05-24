#!/bin/sh
# s4darc - Arch Linux Installer
# Lightweight installer - no compilation needed!
# Usage: bash <(curl -fsSL https://raw.githubusercontent.com/Sadbin47/s4darc/main/s4darc.sh)

set -e

RC='\033[0m'
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
CYAN='\033[36m'
BOLD='\033[1m'

clear
printf "%b\n" "${CYAN}${BOLD}"
printf "    s4darc\n"
printf "    Arch Linux Installer v1.0.0\n"
printf "%b\n\n" "${RC}"

INSTALL_DIR="/root/s4darc"

# Check environment
check_environment() {
    printf "%b\n" "${YELLOW}Checking environment...${RC}"
    
    if [ "$(id -u)" -ne 0 ]; then
        printf "%b\n" "${RED}Error: Run as root!${RC}"
        exit 1
    fi
    
    if [ ! -f /etc/arch-release ]; then
        printf "%b\n" "${RED}Error: Run from Arch Linux Live ISO${RC}"
        exit 1
    fi
    
    # Skip ping check - git/curl will fail if no internet anyway
    
    printf "%b\n" "${GREEN}Environment OK!${RC}"
}

# Download scripts only (no compilation!)
download_scripts() {
    printf "%b\n" "${YELLOW}Downloading installer scripts...${RC}"
    
    rm -rf "$INSTALL_DIR"
    mkdir -p "$INSTALL_DIR"
    
    # Just download the scripts - no C++ needed!
    git clone --depth 1 https://github.com/Sadbin47/s4darc.git "$INSTALL_DIR" 2>/dev/null || {
        # Fallback: download individual files if git fails
        printf "%b\n" "${YELLOW}Downloading files directly...${RC}"
        mkdir -p "$INSTALL_DIR/scripts" "$INSTALL_DIR/tui"
        
        BASE_URL="https://raw.githubusercontent.com/Sadbin47/s4darc/main"
        
        for script in common.sh 00-check-environment.sh 01-partition-disk.sh \
                      02-format-partitions.sh 03-mount-partitions.sh 04-install-base.sh \
                      05-generate-fstab.sh 06-configure-system.sh 07-setup-users.sh \
                      08-install-bootloader.sh 09-finalize.sh; do
            curl -fsSL "$BASE_URL/scripts/$script" -o "$INSTALL_DIR/scripts/$script"
        done
        
        for module in header.sh disk.sh kernel.sh system.sh users.sh summary.sh install.sh; do
            curl -fsSL "$BASE_URL/tui/$module" -o "$INSTALL_DIR/tui/$module"
        done
        
        curl -fsSL "$BASE_URL/s4darc.sh" -o "$INSTALL_DIR/s4darc.sh"
        curl -fsSL "$BASE_URL/s4dutil" -o "$INSTALL_DIR/s4dutil"
    }
    
    chmod +x "$INSTALL_DIR"/*.sh "$INSTALL_DIR"/scripts/*.sh "$INSTALL_DIR"/tui/*.sh 2>/dev/null || true
    
    printf "%b\n" "${GREEN}Download complete!${RC}"
}

# Install command wrappers
install_commands() {
    printf "%b\n" "${YELLOW}Installing commands...${RC}"

    install -Dm755 "$INSTALL_DIR/s4darc.sh" /usr/local/bin/s4darc

    if [ ! -f "$INSTALL_DIR/s4dutil" ]; then
        {
            printf '%s\n' '#!/usr/bin/env bash'
            printf '%s\n' 'echo "s4dutil has been renamed to s4darc."'
            printf '%s\n' 'echo "Launching s4darc..."'
            printf '%s\n' 'exec s4darc "$@"'
        } > "$INSTALL_DIR/s4dutil"
        chmod +x "$INSTALL_DIR/s4dutil"
    fi

    install -Dm755 "$INSTALL_DIR/s4dutil" /usr/local/bin/s4dutil

    printf "%b\n" "${GREEN}Commands installed: s4darc, s4dutil compatibility wrapper${RC}"
}

# Run the main installer
run_installer() {
    cd "$INSTALL_DIR"
    # Use exec with proper TTY to allow user input
    exec sh ./s4darc.sh < /dev/tty
}

main() {
    check_environment
    download_scripts
    install_commands
    run_installer
}

main "$@"
