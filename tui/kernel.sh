#!/bin/sh
# S4DArc - Kernel & Bootloader Selection Module

# Select kernel
select_kernel() {
    printf "    %b󰌽%b  %bChoose your Linux kernel%b %b[Default: linux]%b\n" "${PURPLE}" "${RC}" "${WHITE}" "${RC}" "${DIM}${CYAN}" "${RC}"
    printf "\n"
    printf "      %b1%b) %blinux%b              %b(Stable — default latest kernel)%b\n" "${CYAN}${BOLD}" "${RC}" "${WHITE}" "${RC}" "${DIM}" "${RC}"
    printf "      %b2%b) %blinux-lqx%b          %b(Liquorix — low-latency, gaming, A/V)%b\n" "${CYAN}${BOLD}" "${RC}" "${WHITE}" "${RC}" "${DIM}" "${RC}"
    printf "      %b3%b) %blinux-lts%b          %b(Long Term Support — maximum stability)%b\n" "${CYAN}${BOLD}" "${RC}" "${WHITE}" "${RC}" "${DIM}" "${RC}"
    printf "      %b4%b) %blinux-zen%b          %b(Zen — optimized for desktop responsiveness)%b\n" "${CYAN}${BOLD}" "${RC}" "${WHITE}" "${RC}" "${DIM}" "${RC}"
    printf "      %b5%b) %blinux-hardened%b     %b(Hardened — security-focused patches)%b\n" "${CYAN}${BOLD}" "${RC}" "${WHITE}" "${RC}" "${DIM}" "${RC}"
    printf "      %b6%b) %blinux-rt%b           %b(Realtime — maximum preemption)%b\n" "${CYAN}${BOLD}" "${RC}" "${WHITE}" "${RC}" "${DIM}" "${RC}"
    printf "\n       %b➜%b " "${CYAN}" "${RC}"
    read -r kernel_choice

    case "$kernel_choice" in
        1) KERNEL="linux" ;;
        2) KERNEL="linux-lqx" ;;
        3) KERNEL="linux-lts" ;;
        4) KERNEL="linux-zen" ;;
        5) KERNEL="linux-hardened" ;;
        6) KERNEL="linux-rt" ;;
        *) KERNEL="linux" ;;
    esac

    # Resolve display name for confirmation
    case "$KERNEL" in
        linux)     _kname="Linux (Stable)" ;;
        linux-lqx) _kname="Liquorix" ;;
        linux-lts) _kname="Linux LTS" ;;
        linux-zen) _kname="Linux Zen" ;;
        linux-hardened) _kname="Linux Hardened" ;;
        linux-rt)  _kname="Linux Realtime" ;;
        *)         _kname="$KERNEL" ;;
    esac
    ok "Kernel: $_kname ($KERNEL)"
}

# Resolve kernel package name to display name
resolve_kernel_name() {
    case "$1" in
        linux)          echo "Linux (Stable)" ;;
        linux-lqx)      echo "Liquorix" ;;
        linux-lts)      echo "Linux LTS" ;;
        linux-zen)      echo "Linux Zen" ;;
        linux-hardened) echo "Linux Hardened" ;;
        linux-rt)       echo "Linux Realtime" ;;
        *)              echo "$1" ;;
    esac
}

# Kernel and Bootloader selection page
select_kernel_bootloader() {
    show_header

    # Detect UEFI mode
    if [ -d /sys/firmware/efi ]; then
        IS_UEFI=1
    else
        IS_UEFI=0
    fi

    printf "  %b╭─────────────────────────────────────────────╮%b\n" "${CYAN}" "${RC}"
    printf "  %b│%b %b󰌽  Kernel & Bootloader%b                       %b│%b\n" "${CYAN}" "${RC}" "${BOLD}${WHITE}" "${RC}" "${CYAN}" "${RC}"
    printf "  %b╰─────────────────────────────────────────────╯%b\n" "${CYAN}" "${RC}"
    printf "\n"

    # Kernel selection
    select_kernel

    # Bootloader selection
    printf "\n"
    printf "    %b󰋊%b  %bBootloader Selection%b\n" "${PURPLE}" "${RC}" "${WHITE}${BOLD}" "${RC}"
    printf "\n"
    printf "      %b1%b) %bGRUB%b              %b(feature-rich, dual-boot support)%b\n" "${CYAN}${BOLD}" "${RC}" "${WHITE}" "${RC}" "${DIM}" "${RC}"

    if [ "$IS_UEFI" = "1" ]; then
        printf "      %b2%b) %bsystemd-boot%b      %b(minimal, fast, modern - UEFI only)%b\n" "${CYAN}${BOLD}" "${RC}" "${WHITE}" "${RC}" "${DIM}" "${RC}"
    else
        printf "      %b2%b) %bsystemd-boot%b      %b(requires UEFI - not available)%b\n" "${DIM}" "${RC}" "${DIM}" "${RC}" "${RED}${DIM}" "${RC}"
    fi

    printf "\n       %b➜%b " "${CYAN}" "${RC}"
    read -r boot_choice

    case "$boot_choice" in
        2)
            if [ "$IS_UEFI" = "1" ]; then
                BOOTLOADER="systemd-boot"
                ok "Bootloader: systemd-boot"
            else
                warn "systemd-boot requires UEFI! Defaulting to GRUB."
                BOOTLOADER="grub"
                ok "Bootloader: GRUB (BIOS mode)"
            fi
            ;;
        *)
            BOOTLOADER="grub"
            if [ "$IS_UEFI" = "1" ]; then
                ok "Bootloader: GRUB (UEFI)"
            else
                ok "Bootloader: GRUB (BIOS)"
            fi
            ;;
    esac

    # Export variables
    export S4D_BOOTLOADER="$BOOTLOADER"
    export S4D_IS_UEFI="$IS_UEFI"
    export S4D_KERNEL="$KERNEL"

    printf "\n"
    ok "Kernel & Bootloader configured!"
    sleep 1
}
