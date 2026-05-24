#!/bin/sh
# S4DArc - Step 9: Finalize Installation
# Final cleanup and preparation for reboot

. "$(dirname "$0")/common.sh"

check_root

info "Finalizing installation..."

###################
# Sync filesystems
###################
info "Syncing filesystems..."
sync

###################
# Unmount partitions
###################
info "Unmounting partitions..."

# Disable swap
swapoff -a 2>/dev/null || true

# Unmount all partitions recursively
umount -R /mnt 2>/dev/null || true

success "Partitions unmounted"

###################
# Final message
###################
echo ""
echo "=============================================="
echo ""
success "Arch Linux installation complete!"
echo ""
echo "  You can now reboot into your new system."
echo "  Remember to remove the installation media!"
echo ""
echo "  After rebooting, log in as root or your user"
echo "  and continue setting up your system."
echo ""
echo "=============================================="
echo ""

success "Installation finalized!"
