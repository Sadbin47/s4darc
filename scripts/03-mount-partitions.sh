#!/bin/sh
# S4DArc - Step 3: Mount Partitions
# Mounts the partitions to /mnt for installation

. "$(dirname "$0")/common.sh"

check_root
validate_env

DISK="$S4D_TARGET_DISK"

info "Mounting partitions..."

# Ensure /mnt is not in use
umount -R /mnt 2>/dev/null || true

if is_uefi; then
    ###################
    # UEFI Mounting
    ###################
    EFI_PART=$(get_partition "$DISK" 1)
    ROOT_PART=$(get_partition "$DISK" 2)
    
    # Mount root partition
    info "Mounting root partition ($ROOT_PART) to /mnt..."
    mount "$ROOT_PART" /mnt
    success "Root partition mounted"
    
    # Create and mount EFI directory
    info "Mounting EFI partition ($EFI_PART) to /mnt/boot/efi..."
    mkdir -p /mnt/boot/efi
    mount "$EFI_PART" /mnt/boot/efi
    success "EFI partition mounted"
    
else
    ###################
    # BIOS Mounting
    ###################
    ROOT_PART=$(get_partition "$DISK" 1)
    
    # Mount root partition
    info "Mounting root partition ($ROOT_PART) to /mnt..."
    mount "$ROOT_PART" /mnt
    success "Root partition mounted"
fi

# Verify mounts
info "Current mount points:"
lsblk "$DISK"

success "All partitions mounted successfully!"
