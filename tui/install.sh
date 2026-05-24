#!/bin/sh
# s4darc - Installation Runner Module
# Executes installation steps with live progress display

# Run installation
run_installation() {
    SCRIPTS_DIR="$SCRIPT_DIR/scripts"
    LOG_FILE="/tmp/s4darc_install.log"
    : > "$LOG_FILE"  # Clear log file

    steps="00-check-environment.sh
01-partition-disk.sh
02-format-partitions.sh
03-mount-partitions.sh
04-install-base.sh
05-generate-fstab.sh
06-configure-system.sh
07-setup-users.sh
08-install-bootloader.sh
09-finalize.sh"

    total=$(echo "$steps" | wc -l)
    current=0

    # Store step statuses (0=pending, 1=running, 2=done, 3=failed)
    step_status=""
    for i in $(seq 1 $total); do
        step_status="${step_status}0"
    done

    # Function to redraw the screen with live progress
    redraw_screen() {
        clear
        printf "\n"
        printf "    %bs4darc%b\n" "${GRAD1}${BOLD}" "${RC}"
        printf "\n"
        printf "    %bArch Linux Installer v1.0%b\n" "${DIM}" "${RC}"
        printf "\n"

        printf "  %b╭─────────────────────────────────────────────╮%b\n" "${CYAN}" "${RC}"
        printf "  %b│%b %b󰚰  Installing Arch Linux...%b                  %b│%b\n" "${CYAN}" "${RC}" "${BOLD}${WHITE}" "${RC}" "${CYAN}" "${RC}"
        printf "  %b╰─────────────────────────────────────────────╯%b\n" "${CYAN}" "${RC}"
        printf "\n"

        # Show all steps with their status
        idx=0
        echo "$steps" | while IFS= read -r s; do
            idx=$((idx + 1))
            sname=$(echo "$s" | sed 's/[0-9]*-//;s/\.sh//;s/-/ /g')
            pct=$((idx * 100 / total))

            # Get status for this step
            stat=$(echo "$step_status" | cut -c"$idx")

            case "$stat" in
                0) # Pending
                    printf "    %b○%b  %b%3d%%%b  %b%-25s%b\n" "${DIM}" "${RC}" "${DIM}" "$pct" "${RC}" "${DIM}" "$sname" "${RC}"
                    ;;
                1) # Running
                    printf "    %b◐%b  %b%3d%%%b  %b%-25s%b %b...%b\n" "${YELLOW}" "${RC}" "${YELLOW}" "$pct" "${RC}" "${WHITE}${BOLD}" "$sname" "${RC}" "${YELLOW}" "${RC}"
                    ;;
                2) # Done
                    printf "    %b✓%b  %b%3d%%%b  %b%-25s%b\n" "${GREEN}${BOLD}" "${RC}" "${GREEN}" "$pct" "${RC}" "${WHITE}" "$sname" "${RC}"
                    ;;
                3) # Failed
                    printf "    %b✗%b  %b%3d%%%b  %b%-25s%b\n" "${RED}${BOLD}" "${RC}" "${RED}" "$pct" "${RC}" "${WHITE}" "$sname" "${RC}"
                    ;;
            esac
        done

        printf "\n"

        # Live log box
        printf "  %b╭───────────────────────────────────────────────────────────────╮%b\n" "${DIM}" "${RC}"
        printf "  %b│%b %b󰎚   Log's%b                                                   %b│%b\n" "${DIM}" "${RC}" "${CYAN}${BOLD}" "${RC}" "${DIM}" "${RC}"
        printf "  %b├───────────────────────────────────────────────────────────────┤%b\n" "${DIM}" "${RC}"

        # Show last 8 lines of log
        if [ -f "$LOG_FILE" ] && [ -s "$LOG_FILE" ]; then
            tail -8 "$LOG_FILE" | while IFS= read -r logline; do
                truncated=$(echo "$logline" | cut -c1-63)
                printf "  %b%b  %b%-63s%b%b%b\n" "${DIM}" "${RC}" "${CYAN}" "$truncated" "${RC}" "${DIM}" "${RC}"
            done
        else
            printf "  %b│%b  %b%-63s%b%b│%b\n" "${DIM}" "${RC}" "${DIM}" "Waiting for output..." "${RC}" "${DIM}" "${RC}"
        fi

        printf "  %b╰───────────────────────────────────────────────────────────────╯%b\n" "${DIM}" "${RC}"
    }

    for step in $steps; do
        current=$((current + 1))
        step_name=$(echo "$step" | sed 's/[0-9]*-//;s/\.sh//;s/-/ /g')

        # Update status to running
        step_status=$(echo "$step_status" | sed "s/./1/$current")
        redraw_screen

        # Log separator
        printf "\n=== %s ===\n" "$step_name" >> "$LOG_FILE"

        # Run script and capture output
        if sh "$SCRIPTS_DIR/$step" </dev/null >> "$LOG_FILE" 2>&1; then
            # Update status to done
            step_status=$(echo "$step_status" | sed "s/./2/$current")
        else
            # Update status to failed
            step_status=$(echo "$step_status" | sed "s/./3/$current")
            redraw_screen
            printf "\n"
            err "Installation failed at step: $step"
            printf "  %bCheck log: %s%b\n" "${DIM}" "$LOG_FILE" "${RC}"
            exit 1
        fi

        # Redraw with updated status
        redraw_screen
    done

    printf "\n  %b󰎚  Full log saved to: %s%b\n" "${DIM}" "$LOG_FILE" "${RC}"

    # Installation complete
    printf "\n"
    ok "Installation Complete!"
    printf "\n"
    printf "  %bYou can now reboot into your new system.%b\n" "${WHITE}" "${RC}"
    warn "Remember to remove the installation media!"
    printf "\n"

    printf "  %bReboot now?%b %b[Y/n]%b: " "${WHITE}${BOLD}" "${RC}" "${DIM}" "${RC}"
    read -r reboot_choice
    case "$reboot_choice" in
        [Nn]*) ;;
        *) reboot ;;
    esac
}
