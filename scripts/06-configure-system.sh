#!/bin/sh
# S4DArc - Step 6: Configure System
# Configures timezone, locale, hostname, etc.

. "$(dirname "$0")/common.sh"

check_root
validate_env

info "Configuring system..."

###################
# Timezone
###################
info "Setting timezone to $S4D_TIMEZONE..."
arch_chroot "ln -sf /usr/share/zoneinfo/$S4D_TIMEZONE /etc/localtime"
arch_chroot "hwclock --systohc"
success "Timezone set"

###################
# Locale
###################
info "Configuring locale ($S4D_LOCALE)..."

# Uncomment the locale in locale.gen
sed -i "s/^#$S4D_LOCALE/$S4D_LOCALE/" /mnt/etc/locale.gen

# Also enable en_US.UTF-8 as fallback
sed -i 's/^#en_US.UTF-8/en_US.UTF-8/' /mnt/etc/locale.gen

# Generate locales
arch_chroot "locale-gen"

# Set default locale
echo "LANG=$S4D_LOCALE" > /mnt/etc/locale.conf

success "Locale configured"

###################
# Keyboard
###################
if [ -n "$S4D_KEYMAP" ]; then
    info "Setting keyboard layout to $S4D_KEYMAP..."
    echo "KEYMAP=$S4D_KEYMAP" > /mnt/etc/vconsole.conf
    success "Keyboard layout set"
fi

###################
# Hostname
###################
info "Setting hostname to $S4D_HOSTNAME..."
echo "$S4D_HOSTNAME" > /mnt/etc/hostname

# Configure hosts file
cat > /mnt/etc/hosts << EOF
127.0.0.1   localhost
::1         localhost
127.0.1.1   $S4D_HOSTNAME.localdomain $S4D_HOSTNAME
EOF

success "Hostname configured"

###################
# Network
###################
info "Enabling NetworkManager..."
arch_chroot "systemctl enable NetworkManager"
success "NetworkManager enabled"

###################
# Initramfs
###################
info "Regenerating initramfs..."
arch_chroot "mkinitcpio -P"
success "Initramfs regenerated"

###################
# Swap File
###################
if [ "$S4D_SWAP_SIZE" -gt 0 ] 2>/dev/null; then
    info "Creating ${S4D_SWAP_SIZE}GB swap file..."
    
    # Calculate size in bytes
    SWAP_BYTES=$((S4D_SWAP_SIZE * 1024 * 1024 * 1024))
    
    # Create swap file using dd (XFS doesn't support fallocate for swap)
    dd if=/dev/zero of=/mnt/swapfile bs=1M count=$((S4D_SWAP_SIZE * 1024)) status=progress
    
    # Set permissions
    chmod 600 /mnt/swapfile
    
    # Format as swap
    mkswap /mnt/swapfile
    
    # Add to fstab
    echo "/swapfile none swap defaults 0 0" >> /mnt/etc/fstab
    
    # Set swappiness (lower = less aggressive swapping)
    echo "vm.swappiness=10" > /mnt/etc/sysctl.d/99-swappiness.conf
    
    success "Swap file created and configured"
else
    info "Swap file disabled, skipping..."
fi

success "System configuration complete!"
