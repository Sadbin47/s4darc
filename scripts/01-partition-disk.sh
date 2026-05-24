#!/bin/sh
# S4DArc - Step 1: Partition Disk
# Creates partitions on the target disk (No swap partition - uses swap file)

. "$(dirname "$0")/common.sh"

check_root
validate_env

DISK="$S4D_TARGET_DISK"

info "Partitioning disk: $DISK"
warn "This will ERASE ALL DATA on $DISK!"

# Unmount any existing partitions
unmount_disk "$DISK"

# Ensure parted is installed
if ! command -v parted >/dev/null 2>&1; then
    info "Installing parted..."
    pacman -Sy --noconfirm parted </dev/null
fi

# Wipe existing partition table
info "Wiping existing partition table..."
wipefs -af "$DISK" >/dev/null 2>&1 || true
dd if=/dev/zero of="$DISK" bs=512 count=34 >/dev/null 2>&1 || true

if is_uefi; then
    ###################
    # UEFI Partitioning (GPT: EFI + Root)
    ###################
    info "Creating GPT partition table for UEFI..."
    
    EFI_SIZE="${S4D_EFI_SIZE:-512}"
    
    info "EFI partition: ${EFI_SIZE}MB"
    info "Root partition: remaining space (XFS)"
    
    # Create GPT partition table with parted
    parted -s "$DISK" mklabel gpt
    
    # 1. EFI System Partition (1MB to 513MB)
    parted -s "$DISK" mkpart "EFI" fat32 1MiB "${EFI_SIZE}MiB"
    parted -s "$DISK" set 1 esp on
    
    # 2. Root partition (remaining space)
    parted -s "$DISK" mkpart "root" xfs "${EFI_SIZE}MiB" 100%
    
else
    ###################
    # BIOS Partitioning (MBR: Root only)
    ###################
    info "Creating MBR partition table for BIOS..."
    info "Root partition: entire disk (XFS)"
    
    # Create MBR partition table with parted
    parted -s "$DISK" mklabel msdos
    
    # Single root partition (entire disk)
    parted -s "$DISK" mkpart primary xfs 1MiB 100%
    parted -s "$DISK" set 1 boot on
fi

# Wait for kernel to recognize partitions
wait_for_disk "$DISK"

# Verify partitions were created
info "Verifying partitions..."
lsblk "$DISK"

if is_uefi; then
    part1=$(get_partition "$DISK" 1)
    part2=$(get_partition "$DISK" 2)
    
    [ -b "$part1" ] || { error "EFI partition not found"; exit 1; }
    [ -b "$part2" ] || { error "Root partition not found"; exit 1; }
else
    part1=$(get_partition "$DISK" 1)
    
    [ -b "$part1" ] || { error "Root partition not found"; exit 1; }
fi

success "Disk partitioned successfully!"
