#!/bin/sh
# S4DArc - User Setup Module
# hostname, root password, and user account creation

# Setup users
setup_users() {
    show_header

    printf "  %b╭─────────────────────────────────────────────╮%b\n" "${CYAN}" "${RC}"
    printf "  %b│%b %b󰀄  User Setup%b                                %b%b\n" "${CYAN}" "${RC}" "${BOLD}${WHITE}" "${RC}" "${CYAN}" "${RC}"
    printf "  %b╰─────────────────────────────────────────────╯%b\n" "${CYAN}" "${RC}"
    printf "\n"

    # Hostname
    printf "    %b󰇄%b  %bHostname%b %b[Default: %s]%b\n" "${PURPLE}" "${RC}" "${WHITE}" "${RC}" "${DIM}${CYAN}" "$HOSTNAME" "${RC}"
    printf "       %b➜%b " "${CYAN}" "${RC}"
    read -r input
    [ -n "$input" ] && HOSTNAME="$input"
    ok "Hostname: $HOSTNAME"
    printf "\n"

    # Root password
    printf "    %b󰌋%b  %bRoot Password%b\n" "${PURPLE}" "${RC}" "${WHITE}${BOLD}" "${RC}"
    while true; do
        printf "       %b➜%b Enter password: " "${RED}" "${RC}"
        stty -echo
        read -r ROOT_PASSWORD
        stty echo
        printf "\n"

        printf "       %b➜%b Confirm password: " "${RED}" "${RC}"
        stty -echo
        read -r confirm
        stty echo
        printf "\n"

        if [ "$ROOT_PASSWORD" = "$confirm" ] && [ -n "$ROOT_PASSWORD" ]; then
            ok "Root password set!"
            break
        else
            err "Passwords don't match or empty. Try again."
            printf "\n"
        fi
    done

    # Create user?
    printf "\n"
    printf "    %b󰀄%b  %bCreate a regular user?%b %b[Y/n]%b: " "${PURPLE}" "${RC}" "${WHITE}" "${RC}" "${DIM}" "${RC}"
    read -r create_user

    case "$create_user" in
        [Nn]*)
            USERNAME=""
            ;;
        *)
            printf "\n"
            printf "    %b󰀄%b  %bUsername%b\n" "${PURPLE}" "${RC}" "${WHITE}${BOLD}" "${RC}"
            printf "       %b➜%b " "${CYAN}" "${RC}"
            read -r USERNAME

            printf "\n"
            printf "    %b󰌋%b  %bPassword for %s%b\n" "${PURPLE}" "${RC}" "${WHITE}${BOLD}" "$USERNAME" "${RC}"
            while true; do
                printf "       %b➜%b Enter password: " "${CYAN}" "${RC}"
                stty -echo
                read -r USER_PASSWORD
                stty echo
                printf "\n"

                printf "       %b➜%b Confirm password: " "${CYAN}" "${RC}"
                stty -echo
                read -r confirm
                stty echo
                printf "\n"

                if [ "$USER_PASSWORD" = "$confirm" ] && [ -n "$USER_PASSWORD" ]; then
                    ok "User password set!"
                    break
                else
                    err "Passwords don't match or empty. Try again."
                    printf "\n"
                fi
            done
            ;;
    esac

    export S4D_HOSTNAME="$HOSTNAME"
    export S4D_ROOT_PASSWORD="$ROOT_PASSWORD"
    export S4D_USERNAME="$USERNAME"
    export S4D_USER_PASSWORD="$USER_PASSWORD"

    sleep 1
}
