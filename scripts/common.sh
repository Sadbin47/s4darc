#!/bin/sh
# S4DArc - Common functions for installation scripts
# This file is sourced by all installation scripts

set -e

# ═══════════════════════════════════════════════════════════════
#                         COLOR DEFINITIONS
# ═══════════════════════════════════════════════════════════════

# Reset
RC='\033[0m'
NC='\033[0m'

# Regular Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
ORANGE='\033[0;33m'

# Text Styles
BOLD='\033[1m'
DIM='\033[2m'
ITALIC='\033[3m'
UNDERLINE='\033[4m'
BLINK='\033[5m'

# Background Colors
BG_RED='\033[41m'
BG_GREEN='\033[42m'
BG_YELLOW='\033[43m'
BG_BLUE='\033[44m'
BG_PURPLE='\033[45m'
BG_CYAN='\033[46m'

# Gradient colors (24-bit true color — cyan → purple)
GRAD1='\033[38;2;0;255;255m'    # Cyan
GRAD2='\033[38;2;0;210;255m'    # Sky blue
GRAD3='\033[38;2;0;170;255m'    # Blue
GRAD4='\033[38;2;60;130;255m'   # Indigo
GRAD5='\033[38;2;120;90;255m'   # Violet
GRAD6='\033[38;2;170;60;255m'   # Purple

# Accent colors
ACCENT1='\033[38;5;213m'  # Pink
ACCENT2='\033[38;5;141m'  # Light purple
ACCENT3='\033[38;5;183m'  # Lavender

# ═══════════════════════════════════════════════════════════════
#                     STATUS OUTPUT FUNCTIONS
# ═══════════════════════════════════════════════════════════════

# Colored status functions with icons
ok() {
    printf "%b\n" "${GREEN}${BOLD}  ✓${RC} ${WHITE}$1${RC}"
}

info() {
    printf "%b\n" "${BLUE}${BOLD}  ℹ${RC} ${WHITE}$1${RC}"
}

warn() {
    printf "%b\n" "${YELLOW}${BOLD}  ⚠${RC} ${YELLOW}$1${RC}"
}

err() {
    printf "%b\n" "${RED}${BOLD}  ✗${RC} ${RED}$1${RC}"
}

error() {
    printf "%b\n" "${RED}${BOLD}  ✗${RC} ${RED}$1${RC}"
}

success() {
    printf "%b\n" "${GREEN}${BOLD}  ✓${RC} ${GREEN}$1${RC}"
}

step() {
    printf "%b\n" "${CYAN}${BOLD}  ➤${RC} ${WHITE}$1${RC}"
}

# ═══════════════════════════════════════════════════════════════
#                      PROGRESS BAR FUNCTION
# ═══════════════════════════════════════════════════════════════

progress_bar() {
    current=$1
    total=$2
    width=${3:-40}
    
    percent=$((current * 100 / total))
    filled=$((current * width / total))
    empty=$((width - filled))
    
    # Build the bar
    bar_filled=""
    bar_empty=""
    i=0
    while [ $i -lt $filled ]; do
        bar_filled="${bar_filled}█"
        i=$((i + 1))
    done
    i=0
    while [ $i -lt $empty ]; do
        bar_empty="${bar_empty}░"
        i=$((i + 1))
    done
    
    printf "\r  ${CYAN}[${GRAD3}%s${DIM}%s${CYAN}]${RC} ${WHITE}${BOLD}%3d%%${RC} " "$bar_filled" "$bar_empty" "$percent"
}

# ═══════════════════════════════════════════════════════════════
#                    SECTION HEADER FUNCTION
# ═══════════════════════════════════════════════════════════════

section() {
    title="$1"
    printf "\n"
    printf "  %b╭─────────────────────────────────────────────╮%b\n" "${PURPLE}" "${RC}"
    printf "  %b│%b %b%-43s%b %b│%b\n" "${PURPLE}" "${RC}" "${BOLD}${WHITE}" "$title" "${RC}" "${PURPLE}" "${RC}"
    printf "  %b╰─────────────────────────────────────────────╯%b\n" "${PURPLE}" "${RC}"
    printf "\n"
}

# ═══════════════════════════════════════════════════════════════
#                     SPINNER FUNCTION
# ═══════════════════════════════════════════════════════════════

spinner() {
    pid=$1
    msg=$2
    spin='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    i=0
    while kill -0 "$pid" 2>/dev/null; do
        i=$(( (i + 1) % 10 ))
        char=$(echo "$spin" | cut -c$((i + 1)))
        printf "\r  ${CYAN}[${char}]${RC} ${WHITE}%s${RC}" "$msg"
        sleep 0.1
    done
    printf "\r  ${GREEN}${BOLD}[✓]${RC} ${WHITE}%s${RC}\n" "$msg"
}

# Spinner with custom end state
spinner_fail() {
    pid=$1
    msg=$2
    spin='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    i=0
    while kill -0 "$pid" 2>/dev/null; do
        i=$(( (i + 1) % 10 ))
        char=$(echo "$spin" | cut -c$((i + 1)))
        printf "\r  ${CYAN}[${char}]${RC} ${WHITE}%s${RC}" "$msg"
        sleep 0.1
    done
    printf "\r  ${RED}${BOLD}[✗]${RC} ${RED}%s${RC}\n" "$msg"
}

# ═══════════════════════════════════════════════════════════════
#                    DECORATIVE ELEMENTS
# ═══════════════════════════════════════════════════════════════

# Horizontal line
draw_line() {
    width=${1:-50}
    char=${2:-─}
    line=""
    i=0
    while [ $i -lt $width ]; do
        line="${line}${char}"
        i=$((i + 1))
    done
    printf "  %b%s%b\n" "${DIM}${CYAN}" "$line" "${RC}"
}

# Box drawing
draw_box_top() {
    width=${1:-50}
    line=""
    i=0
    while [ $i -lt $((width - 2)) ]; do
        line="${line}═"
        i=$((i + 1))
    done
    printf "  %b╔%s╗%b\n" "${PURPLE}" "$line" "${RC}"
}

draw_box_bottom() {
    width=${1:-50}
    line=""
    i=0
    while [ $i -lt $((width - 2)) ]; do
        line="${line}═"
        i=$((i + 1))
    done
    printf "  %b╚%s╝%b\n" "${PURPLE}" "$line" "${RC}"
}

draw_box_mid() {
    width=${1:-50}
    line=""
    i=0
    while [ $i -lt $((width - 2)) ]; do
        line="${line}═"
        i=$((i + 1))
    done
    printf "  %b╠%s╣%b\n" "${PURPLE}" "$line" "${RC}"
}

# ═══════════════════════════════════════════════════════════════
#                    PROMPT HELPERS
# ═══════════════════════════════════════════════════════════════

# Show default value in prompt
prompt_with_default() {
    prompt_text="$1"
    default_val="$2"
    printf "  %b%s%b %b[Default: %s]%b: " "${WHITE}" "$prompt_text" "${RC}" "${DIM}${CYAN}" "$default_val" "${RC}"
}

# Confirmation prompt
confirm_action() {
    msg="$1"
    default="${2:-n}"
    
    if [ "$default" = "y" ]; then
        prompt="[Y/n]"
    else
        prompt="[y/N]"
    fi
    
    printf "  %b%s%b %b%s%b: " "${WHITE}" "$msg" "${RC}" "${DIM}" "$prompt" "${RC}"
}

# Check if running as root
check_root() {
    if [ "$(id -u)" -ne 0 ]; then
        error "This script must be run as root"
        exit 1
    fi
}

# Check if on Arch Live ISO
check_live_iso() {
    if [ ! -f /etc/arch-release ]; then
        error "This script must be run on Arch Linux"
        exit 1
    fi
}

# Check internet connection
check_internet() {
    if ! ping -c 1 -W 5 1.1.1.1 >/dev/null 2>&1 && \
       ! ping -c 1 -W 5 8.8.8.8 >/dev/null 2>&1; then
        error "No internet connection"
        exit 1
    fi
}

# Check if UEFI or BIOS
is_uefi() {
    [ -d /sys/firmware/efi ]
}

# Get RAM size in MB
get_ram_mb() {
    awk '/MemTotal/ {print int($2/1024)}' /proc/meminfo
}

# Calculate swap size based on RAM
calculate_swap_size() {
    ram_mb=$(get_ram_mb)
    
    if [ "$ram_mb" -le 2048 ]; then
        # RAM <= 2GB: swap = 2x RAM
        echo $((ram_mb * 2))
    elif [ "$ram_mb" -le 8192 ]; then
        # RAM <= 8GB: swap = RAM
        echo "$ram_mb"
    else
        # RAM > 8GB: swap = 8GB
        echo 8192
    fi
}

# Wait for disk to be ready
wait_for_disk() {
    disk="$1"
    info "Waiting for disk $disk to be ready..."
    sleep 1
    partprobe "$disk" 2>/dev/null || true
    sleep 1
}

# Arch-chroot wrapper (with stdin from /dev/null to prevent hangs)
arch_chroot() {
    arch-chroot /mnt /bin/bash -c "$1" </dev/null
}

# ═══════════════════════════════════════════════════════════════
#                    MEMORY MANAGEMENT
# ═══════════════════════════════════════════════════════════════

# Check available memory and warn if low (returns 0 if OK, 1 if low)
check_memory() {
    min_ram_mb=${1:-1024}  # Default minimum 1GB
    avail_ram=$(awk '/MemAvailable/ {print int($2/1024)}' /proc/meminfo)
    
    [ "$avail_ram" -ge "$min_ram_mb" ]
}

# Create a temporary swap file on the TARGET disk (not tmpfs)
setup_install_swap() {
    total_ram=$(awk '/MemTotal/ {print int($2/1024)}' /proc/meminfo)
    
    # Only create swap if total RAM is low (< 4GB)
    if [ "$total_ram" -lt 4096 ]; then
        info "Low RAM system (${total_ram}MB), creating temporary swap on target..."
        
        # Create swap on /mnt (the target disk, not RAM-backed tmpfs)
        swap_file="/mnt/swapfile_install"
        swap_size=2048  # 2GB
        
        # Make sure /mnt is mounted and has space
        if mountpoint -q /mnt 2>/dev/null; then
            mnt_avail=$(df -m /mnt 2>/dev/null | awk 'NR==2 {print $4}')
            if [ -n "$mnt_avail" ] && [ "$mnt_avail" -gt 2500 ]; then
                # Create swap file
                dd if=/dev/zero of="$swap_file" bs=1M count=$swap_size status=progress 2>/dev/null
                chmod 600 "$swap_file"
                mkswap "$swap_file" >/dev/null 2>&1
                if swapon "$swap_file" 2>/dev/null; then
                    success "Created ${swap_size}MB temporary swap on target disk"
                    echo "$swap_file"
                    return 0
                fi
            fi
        fi
        
        warn "Could not create swap - continuing without it"
    fi
    return 0
}

# Remove temporary swap
cleanup_install_swap() {
    swap_file="$1"
    if [ -n "$swap_file" ] && [ -f "$swap_file" ]; then
        swapoff "$swap_file" 2>/dev/null || true
        rm -f "$swap_file" 2>/dev/null || true
        info "Cleaned up temporary swap"
    fi
}

# Clean up pacman state for fresh attempt
cleanup_pacman_state() {
    target="${1:-/mnt}"
    
    # Kill any hanging pacman/pacstrap processes
    pkill -9 pacman 2>/dev/null || true
    pkill -9 pacstrap 2>/dev/null || true
    sleep 1
    
    # Remove ALL lock files
    rm -f /var/lib/pacman/db.lck 2>/dev/null || true
    rm -f "${target}/var/lib/pacman/db.lck" 2>/dev/null || true
    
    # Sync filesystem
    sync
}

# Run pacstrap with retry logic
run_pacstrap_with_retry() {
    target="$1"
    shift
    packages="$*"
    
    max_retries=3
    retry_count=0
    
    while [ $retry_count -lt $max_retries ]; do
        retry_count=$((retry_count + 1))
        
        info "Running pacstrap (attempt $retry_count/$max_retries)..."
        
        # Clean up before each attempt
        cleanup_pacman_state "$target"
        
        # On retry, do more aggressive cleanup
        if [ $retry_count -gt 1 ]; then
            warn "Retry $retry_count: Performing cleanup..."
            
            # Drop filesystem caches to free memory
            echo 3 > /proc/sys/vm/drop_caches 2>/dev/null || true
            
            # Clear partial downloads
            rm -rf "${target}/var/cache/pacman/pkg"/* 2>/dev/null || true
            
            sleep 2
        fi
        
        # Run pacstrap - show output directly to user
        if pacstrap -K "$target" $packages </dev/null; then
            success "Packages installed successfully"
            return 0
        fi
        
        # pacstrap failed - diagnose
        warn "pacstrap failed (attempt $retry_count/$max_retries)"
        
        # Check for OOM in dmesg
        if dmesg 2>/dev/null | tail -30 | grep -qi "oom\|killed process\|out of memory"; then
            error "Process was killed by OOM killer (out of memory)"
        fi
        
        [ $retry_count -lt $max_retries ] && sleep 3
    done
    
    error "pacstrap failed after $max_retries attempts"
    return 1
}

# Get partition suffix (handles nvme disks)
get_part_suffix() {
    disk="$1"
    case "$disk" in
        /dev/nvme*|/dev/mmcblk*)
            echo "p"
            ;;
        *)
            echo ""
            ;;
    esac
}

# Get partition path
get_partition() {
    disk="$1"
    num="$2"
    suffix=$(get_part_suffix "$disk")
    echo "${disk}${suffix}${num}"
}

# Unmount all partitions from a disk
unmount_disk() {
    disk="$1"
    info "Unmounting any existing partitions on $disk..."
    
    # Unmount /mnt subdirectories first
    umount -R /mnt 2>/dev/null || true
    
    # Unmount all partitions on the disk
    for part in "${disk}"*; do
        if [ -b "$part" ] && [ "$part" != "$disk" ]; then
            umount "$part" 2>/dev/null || true
        fi
    done
    
    # Disable any swap on the disk
    for part in "${disk}"*; do
        if [ -b "$part" ]; then
            swapoff "$part" 2>/dev/null || true
        fi
    done
}

# Validate environment variables
validate_env() {
    required_vars="S4D_TARGET_DISK S4D_HOSTNAME S4D_TIMEZONE S4D_LOCALE"
    
    for var in $required_vars; do
        eval "value=\$$var"
        if [ -z "$value" ]; then
            error "Required environment variable $var is not set"
            exit 1
        fi
    done
}
