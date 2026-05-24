#!/bin/sh
# S4DArc - Step 4: Install Base System
# Installs the base Arch Linux system using pacstrap

. "$(dirname "$0")/common.sh"

check_root
check_internet

info "Installing base system..."

# ═══════════════════════════════════════════════════════════════
#                    SYSTEM INFO
# ═══════════════════════════════════════════════════════════════

# Display memory status
total_ram=$(awk '/MemTotal/ {print int($2/1024)}' /proc/meminfo)
avail_ram=$(awk '/MemAvailable/ {print int($2/1024)}' /proc/meminfo)
info "System memory: ${avail_ram}MB available / ${total_ram}MB total"

# Setup swap for low-RAM systems (only if total RAM < 4GB)
TEMP_SWAP_FILE=""
if [ "$total_ram" -lt 4096 ]; then
    TEMP_SWAP_FILE=$(setup_install_swap)
fi

# Base packages (no kernel - we'll install Liquorix after)
BASE_PACKAGES="base linux-firmware mkinitcpio"

# Essential packages
ESSENTIAL_PACKAGES="base-devel sudo networkmanager vim nano git curl wget"

# Filesystem tools based on selection
FS="${S4D_FILESYSTEM:-ext4}"
case "$FS" in
    xfs)
        FS_PACKAGES="xfsprogs"
        ;;
    btrfs)
        FS_PACKAGES="btrfs-progs"
        ;;
    *)
        FS_PACKAGES="e2fsprogs"
        ;;
esac

# Bootloader packages based on selection
BOOTLOADER="${S4D_BOOTLOADER:-grub}"
info "Selected bootloader: $BOOTLOADER"

if [ "$BOOTLOADER" = "systemd-boot" ]; then
    # systemd-boot only needs efibootmgr (and only works on UEFI)
    if is_uefi; then
        BOOT_PACKAGES="efibootmgr"
        info "systemd-boot selected (UEFI mode)"
    else
        warn "systemd-boot requires UEFI - will fallback to GRUB"
        BOOT_PACKAGES="grub os-prober"
    fi
else
    # GRUB bootloader
    if is_uefi; then
        BOOT_PACKAGES="grub efibootmgr os-prober"
        info "GRUB selected (UEFI mode)"
    else
        BOOT_PACKAGES="grub os-prober"
        info "GRUB selected (BIOS mode)"
    fi
fi

# CPU microcode
CPU_VENDOR=$(grep -m1 'vendor_id' /proc/cpuinfo | awk '{print $3}')
case "$CPU_VENDOR" in
    GenuineIntel)
        MICROCODE="intel-ucode"
        info "Intel CPU detected, adding intel-ucode"
        ;;
    AuthenticAMD)
        MICROCODE="amd-ucode"
        info "AMD CPU detected, adding amd-ucode"
        ;;
    *)
        MICROCODE=""
        warn "Unknown CPU vendor, skipping microcode"
        ;;
esac

# Combine all packages
ALL_PACKAGES="$BASE_PACKAGES $ESSENTIAL_PACKAGES $FS_PACKAGES $BOOT_PACKAGES $MICROCODE"

info "Packages to install:"
echo "  Base:       $BASE_PACKAGES"
echo "  Essential:  $ESSENTIAL_PACKAGES"
echo "  Filesystem: $FS_PACKAGES"
echo "  Bootloader: $BOOT_PACKAGES"
[ -n "$MICROCODE" ] && echo "  Microcode:  $MICROCODE"

# Update mirrorlist for faster downloads (optional)
info "Updating mirror list..."
if command -v reflector >/dev/null 2>&1; then
    reflector --latest 10 --sort rate --save /etc/pacman.d/mirrorlist 2>/dev/null || true
fi

# Clean pacman state before starting
cleanup_pacman_state /mnt

# Run pacstrap with retry logic
if ! run_pacstrap_with_retry /mnt $ALL_PACKAGES; then
    cleanup_install_swap "$TEMP_SWAP_FILE"
    error "Failed to install base packages"
    error "Check the log at /tmp/s4darc_install.log for details"
    exit 1
fi

# ═══════════════════════════════════════════════════════════════
#                    INSTALL SELECTED KERNEL
# ═══════════════════════════════════════════════════════════════

KERNEL="${S4D_KERNEL:-linux}"
info "Selected kernel: $KERNEL"

# Clean state before kernel installation
cleanup_pacman_state /mnt

# ───────────────────────────────────────────────────────────────
#  Kernel-specific installation helpers
# ───────────────────────────────────────────────────────────────

# Install standard repo kernels (linux, linux-lts, linux-zen, linux-hardened, linux-rt)
install_repo_kernel() {
    _kpkg="$1"
    info "Installing ${_kpkg} and ${_kpkg}-headers from official repos..."
    arch_chroot "pacman -S --noconfirm ${_kpkg} ${_kpkg}-headers" </dev/null
}

# Liquorix requires a third-party repo — try multiple methods
install_liquorix_kernel() {
    # Method 1: Try the official Liquorix installer script
    install_liquorix_script() {
        arch_chroot "curl -fsSL 'https://liquorix.net/install-liquorix.sh' | bash -s -- --noconfirm" </dev/null
    }

    # Method 2: Install from chaotic-aur (has pre-built Liquorix packages)
    install_liquorix_chaotic() {
        info "Setting up Chaotic-AUR for Liquorix kernel..."

        # Add chaotic-aur keyring and mirrorlist
        arch_chroot "pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com" </dev/null
        arch_chroot "pacman-key --lsign-key 3056513887B78AEB" </dev/null
        arch_chroot "pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst'" </dev/null
        arch_chroot "pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'" </dev/null

        # Add chaotic-aur to pacman.conf
        if ! grep -q "chaotic-aur" /mnt/etc/pacman.conf; then
            cat >> /mnt/etc/pacman.conf << 'EOF'

# Chaotic-AUR repository
[chaotic-aur]
Include = /etc/pacman.d/chaotic-mirrorlist
EOF
        fi

        # Sync and install
        arch_chroot "pacman -Sy --noconfirm linux-lqx linux-lqx-headers" </dev/null
    }

    if install_liquorix_script 2>/dev/null; then
        success "Liquorix kernel installed via official script"
    elif install_liquorix_chaotic 2>/dev/null; then
        success "Liquorix kernel installed via Chaotic-AUR"
    else
        warn "Could not install Liquorix kernel, falling back to standard Linux kernel..."
        install_repo_kernel "linux"
        success "Standard Linux kernel installed as fallback"
    fi
}

# ───────────────────────────────────────────────────────────────
#  Dispatch to the right installer
# ───────────────────────────────────────────────────────────────

case "$KERNEL" in
    linux-lqx)
        install_liquorix_kernel
        ;;
    linux|linux-lts|linux-zen|linux-hardened|linux-rt)
        if ! install_repo_kernel "$KERNEL"; then
            warn "Failed to install $KERNEL, falling back to standard linux kernel..."
            install_repo_kernel "linux"
        fi
        ;;
    *)
        warn "Unknown kernel '$KERNEL', installing standard linux kernel..."
        install_repo_kernel "linux"
        ;;
esac

# Verify kernel installation
info "Verifying kernel installation..."
FOUND_KERNEL=0
for vmlinuz in /mnt/boot/vmlinuz-*; do
    if [ -f "$vmlinuz" ]; then
        success "Kernel verified: $vmlinuz"
        FOUND_KERNEL=1
    fi
done
if [ "$FOUND_KERNEL" = "0" ]; then
    warn "No kernel found in /mnt/boot — this may cause boot issues!"
fi

# List installed kernels
info "Installed kernels:"
ls -la /mnt/boot/vmlinuz-* 2>/dev/null || warn "No kernel vmlinuz files found"

# Cleanup temporary swap
cleanup_install_swap "$TEMP_SWAP_FILE"

success "Base system installed successfully!"
