#!/bin/sh
# S4DArc - Step 5: Generate fstab
# Generates the filesystem table

. "$(dirname "$0")/common.sh"

check_root

info "Generating fstab..."

# Generate fstab using UUIDs
genfstab -U /mnt >> /mnt/etc/fstab

# Display generated fstab
info "Generated /etc/fstab:"
cat /mnt/etc/fstab

success "fstab generated successfully!"
