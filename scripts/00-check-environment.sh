#!/bin/sh
# S4DArc - Step 0: Check Environment
# Verifies that all requirements are met before installation

. "$(dirname "$0")/common.sh"

info "Checking installation environment..."

# Check root
check_root
success "Running as root"

# Check if on Arch
check_live_iso
success "Running on Arch Linux"

# Check internet
check_internet
success "Internet connection available"

# Check available RAM
total_ram=$(awk '/MemTotal/ {print int($2/1024)}' /proc/meminfo)
avail_ram=$(awk '/MemAvailable/ {print int($2/1024)}' /proc/meminfo)

if [ "$total_ram" -lt 1024 ]; then
    error "Insufficient RAM: ${total_ram}MB total (minimum 1GB required)"
    exit 1
elif [ "$total_ram" -lt 2048 ]; then
    warn "Low RAM detected: ${total_ram}MB (2GB+ recommended)"
    warn "Installation may be slow or fail. Temporary swap will be created."
else
    success "RAM: ${total_ram}MB total, ${avail_ram}MB available"
fi

# Check boot mode
if is_uefi; then
    success "UEFI boot mode detected"
else
    success "BIOS boot mode detected"
fi

# Check target disk exists
if [ -n "$S4D_TARGET_DISK" ]; then
    if [ -b "$S4D_TARGET_DISK" ]; then
        size=$(lsblk -b -d -n -o SIZE "$S4D_TARGET_DISK" 2>/dev/null)
        size_gb=$((size / 1024 / 1024 / 1024))
        success "Target disk $S4D_TARGET_DISK found (${size_gb}GB)"
    else
        error "Target disk $S4D_TARGET_DISK not found"
        exit 1
    fi
fi

# Sync time
timedatectl set-ntp true 2>/dev/null || true

# Update pacman keyring (with proper timeout to prevent hanging)
# Use timeout command if available, otherwise skip if it takes too long
if command -v timeout >/dev/null 2>&1; then
    timeout 30 pacman -Sy --noconfirm archlinux-keyring >/dev/null 2>&1 || true
else
    # Fallback: run in background with manual timeout
    (pacman -Sy --noconfirm archlinux-keyring >/dev/null 2>&1) &
    PACMAN_PID=$!
    COUNT=0
    while kill -0 "$PACMAN_PID" 2>/dev/null; do
        COUNT=$((COUNT + 1))
        if [ "$COUNT" -ge 30 ]; then
            kill "$PACMAN_PID" 2>/dev/null || true
            break
        fi
        sleep 1
    done
fi

success "All environment checks passed!"
