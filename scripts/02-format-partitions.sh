#!/bin/sh
# S4DArc - Step 2: Format Partitions
# Creates filesystems on the partitions

. "$(dirname "$0")/common.sh"

check_root
validate_env

DISK="$S4D_TARGET_DISK"
FS="${S4D_FILESYSTEM:-ext4}"

info "Formatting partitions on $DISK..."

# Format root partition based on selected filesystem
format_root() {
    part="$1"
    case "$FS" in
        xfs)
            info "Formatting root partition ($part) as XFS..."
            mkfs.xfs -f -L "root" "$part"
            success "Root partition formatted (XFS)"
            ;;
        *)
            info "Formatting root partition ($part) as ext4..."
            mkfs.ext4 -F -L "root" "$part"
            success "Root partition formatted (ext4)"
            ;;
    esac
}

if is_uefi; then
    ###################
    # UEFI Formatting
    ###################
    EFI_PART=$(get_partition "$DISK" 1)
    ROOT_PART=$(get_partition "$DISK" 2)
    
    # Format EFI partition as FAT32
    info "Formatting EFI partition ($EFI_PART) as FAT32..."
    mkfs.fat -F 32 -n "EFI" "$EFI_PART"
    success "EFI partition formatted"
    
    # Format root partition
    format_root "$ROOT_PART"
    
else
    ###################
    # BIOS Formatting
    ###################
    ROOT_PART=$(get_partition "$DISK" 1)
    
    # Format root partition
    format_root "$ROOT_PART"
fi

success "All partitions formatted successfully!"
