#!/bin/sh
# S4DArc - System Configuration Module
# timezone, locale, and keyboard layout selection

# ─────────────────────────────────────────────────────────────
#                        LOCALE DATA
# ─────────────────────────────────────────────────────────────

LOCALES="aa_DJ.UTF-8
aa_ER.UTF-8
aa_ET.UTF-8
af_ZA.UTF-8
am_ET.UTF-8
an_ES.UTF-8
ar_AE.UTF-8
ar_BH.UTF-8
ar_DZ.UTF-8
ar_EG.UTF-8
ar_IQ.UTF-8
ar_JO.UTF-8
ar_KW.UTF-8
ar_LB.UTF-8
ar_LY.UTF-8
ar_MA.UTF-8
ar_OM.UTF-8
ar_QA.UTF-8
ar_SA.UTF-8
ar_SD.UTF-8
ar_SY.UTF-8
ar_TN.UTF-8
ar_YE.UTF-8
az_AZ.UTF-8
be_BY.UTF-8
bg_BG.UTF-8
bn_BD.UTF-8
bn_IN.UTF-8
bs_BA.UTF-8
ca_ES.UTF-8
cs_CZ.UTF-8
cy_GB.UTF-8
da_DK.UTF-8
de_AT.UTF-8
de_BE.UTF-8
de_CH.UTF-8
de_DE.UTF-8
de_LU.UTF-8
el_GR.UTF-8
en_AU.UTF-8
en_BW.UTF-8
en_CA.UTF-8
en_DK.UTF-8
en_GB.UTF-8
en_HK.UTF-8
en_IE.UTF-8
en_IN.UTF-8
en_NZ.UTF-8
en_PH.UTF-8
en_SG.UTF-8
en_US.UTF-8
en_ZA.UTF-8
en_ZW.UTF-8
es_AR.UTF-8
es_BO.UTF-8
es_CL.UTF-8
es_CO.UTF-8
es_CR.UTF-8
es_DO.UTF-8
es_EC.UTF-8
es_ES.UTF-8
es_GT.UTF-8
es_HN.UTF-8
es_MX.UTF-8
es_NI.UTF-8
es_PA.UTF-8
es_PE.UTF-8
es_PR.UTF-8
es_PY.UTF-8
es_SV.UTF-8
es_US.UTF-8
es_UY.UTF-8
es_VE.UTF-8
et_EE.UTF-8
eu_ES.UTF-8
fa_IR.UTF-8
fi_FI.UTF-8
fr_BE.UTF-8
fr_CA.UTF-8
fr_CH.UTF-8
fr_FR.UTF-8
fr_LU.UTF-8
ga_IE.UTF-8
gl_ES.UTF-8
gu_IN.UTF-8
he_IL.UTF-8
hi_IN.UTF-8
hr_HR.UTF-8
hu_HU.UTF-8
hy_AM.UTF-8
id_ID.UTF-8
is_IS.UTF-8
it_CH.UTF-8
it_IT.UTF-8
ja_JP.UTF-8
ka_GE.UTF-8
kk_KZ.UTF-8
km_KH.UTF-8
kn_IN.UTF-8
ko_KR.UTF-8
lt_LT.UTF-8
lv_LV.UTF-8
mk_MK.UTF-8
ml_IN.UTF-8
mn_MN.UTF-8
mr_IN.UTF-8
ms_MY.UTF-8
mt_MT.UTF-8
nb_NO.UTF-8
ne_NP.UTF-8
nl_BE.UTF-8
nl_NL.UTF-8
nn_NO.UTF-8
pa_IN.UTF-8
pl_PL.UTF-8
pt_BR.UTF-8
pt_PT.UTF-8
ro_RO.UTF-8
ru_RU.UTF-8
ru_UA.UTF-8
si_LK.UTF-8
sk_SK.UTF-8
sl_SI.UTF-8
sq_AL.UTF-8
sr_RS.UTF-8
sv_FI.UTF-8
sv_SE.UTF-8
ta_IN.UTF-8
te_IN.UTF-8
th_TH.UTF-8
tr_TR.UTF-8
uk_UA.UTF-8
ur_PK.UTF-8
vi_VN.UTF-8
zh_CN.UTF-8
zh_HK.UTF-8
zh_SG.UTF-8
zh_TW.UTF-8"

# ─────────────────────────────────────────────────────────────
#                        KEYMAP DATA
# ─────────────────────────────────────────────────────────────

KEYMAPS="us
uk
by
ca
cf
cz
de
de-latin1
dk
dvorak
es
et
fa
fi
fr
gr
hu
il
it
jp106
la-latin1
lt
lv
mk
nl
no
pl
pt-latin1
ro
ru
se
sg
sk
tr
ua
us-acentos"

# ─────────────────────────────────────────────────────────────
#                     SELECTION FUNCTIONS
# ─────────────────────────────────────────────────────────────

# Select timezone from list
select_timezone() {
    printf "\n"
    printf "      %b1%b) %bUTC%b\n" "${CYAN}${BOLD}" "${RC}" "${WHITE}" "${RC}"
    printf "      %b2%b) %bAmerica/New_York%b\n" "${CYAN}${BOLD}" "${RC}" "${WHITE}" "${RC}"
    printf "      %b3%b) %bAmerica/Los_Angeles%b\n" "${CYAN}${BOLD}" "${RC}" "${WHITE}" "${RC}"
    printf "      %b4%b) %bEurope/London%b\n" "${CYAN}${BOLD}" "${RC}" "${WHITE}" "${RC}"
    printf "      %b5%b) %bAsia/Tokyo%b\n" "${CYAN}${BOLD}" "${RC}" "${WHITE}" "${RC}"
    printf "      %b6%b) %bAsia/Shanghai%b\n" "${CYAN}${BOLD}" "${RC}" "${WHITE}" "${RC}"
    printf "      %b7%b) %bAsia/Dhaka%b\n" "${CYAN}${BOLD}" "${RC}" "${WHITE}" "${RC}"
    printf "      %b8%b) %bEnter custom...%b\n" "${YELLOW}${BOLD}" "${RC}" "${YELLOW}" "${RC}"
    printf "\n       %b➜%b " "${CYAN}" "${RC}"
    read -r tz_choice

    case "$tz_choice" in
        1) TIMEZONE="UTC" ;;
        2) TIMEZONE="America/New_York" ;;
        3) TIMEZONE="America/Los_Angeles" ;;
        4) TIMEZONE="Europe/London" ;;
        5) TIMEZONE="Asia/Tokyo" ;;
        6) TIMEZONE="Asia/Shanghai" ;;
        7) TIMEZONE="Asia/Dhaka" ;;
        8)
            printf "       %bEnter timezone (e.g., Europe/London):%b " "${WHITE}" "${RC}"
            read -r TIMEZONE
            ;;
        *) TIMEZONE="UTC" ;;
    esac
    ok "Timezone set to: $TIMEZONE"
}

# Select locale from all available
select_locale() {
    printf "\n"
    printf "       %bAvailable locales:%b\n" "${WHITE}${BOLD}" "${RC}"
    printf "\n"

    # Display locales in columns
    i=1
    echo "$LOCALES" | while IFS= read -r loc; do
        printf "      %b%2d%b) %b%-20s%b" "${CYAN}${BOLD}" "$i" "${RC}" "${WHITE}" "$loc" "${RC}"
        if [ $((i % 3)) -eq 0 ]; then
            printf "\n"
        fi
        i=$((i + 1))
    done
    printf "\n\n       %b➜%b Enter number or locale name: " "${CYAN}" "${RC}"
    read -r loc_input

    # Check if input is a number
    if echo "$loc_input" | grep -qE '^[0-9]+$'; then
        LOCALE=$(echo "$LOCALES" | sed -n "${loc_input}p")
        [ -z "$LOCALE" ] && LOCALE="en_US.UTF-8"
    else
        # Assume it's a locale name
        if echo "$LOCALES" | grep -q "^${loc_input}$"; then
            LOCALE="$loc_input"
        elif echo "$LOCALES" | grep -q "^${loc_input}"; then
            LOCALE=$(echo "$LOCALES" | grep "^${loc_input}" | head -1)
        else
            LOCALE="en_US.UTF-8"
        fi
    fi
    ok "Locale set to: $LOCALE"
}

# Select keymap from all available
select_keymap() {
    printf "\n"
    printf "       %bAvailable keyboard layouts:%b\n" "${WHITE}${BOLD}" "${RC}"
    printf "\n"

    # Display keymaps in columns
    i=1
    echo "$KEYMAPS" | while IFS= read -r km; do
        printf "      %b%2d%b) %b%-15s%b" "${CYAN}${BOLD}" "$i" "${RC}" "${WHITE}" "$km" "${RC}"
        if [ $((i % 4)) -eq 0 ]; then
            printf "\n"
        fi
        i=$((i + 1))
    done
    printf "\n\n       %b➜%b Enter number or keymap name: " "${CYAN}" "${RC}"
    read -r km_input

    # Check if input is a number
    if echo "$km_input" | grep -qE '^[0-9]+$'; then
        KEYMAP=$(echo "$KEYMAPS" | sed -n "${km_input}p")
        [ -z "$KEYMAP" ] && KEYMAP="us"
    else
        # Assume it's a keymap name
        if echo "$KEYMAPS" | grep -q "^${km_input}$"; then
            KEYMAP="$km_input"
        else
            KEYMAP="us"
        fi
    fi
    ok "Keyboard layout set to: $KEYMAP"
}

# ─────────────────────────────────────────────────────────────
#                  MAIN CONFIGURATION WIZARD
# ─────────────────────────────────────────────────────────────

# Configure system settings (timezone, locale, keyboard)
configure_system() {
    show_header

    printf "  %b╭─────────────────────────────────────────────╮%b\n" "${CYAN}" "${RC}"
    printf "  %b│%b %b󰒓  System Configuration%b                     %b│%b\n" "${CYAN}" "${RC}" "${BOLD}${WHITE}" "${RC}" "${CYAN}" "${RC}"
    printf "  %b╰─────────────────────────────────────────────╯%b\n" "${CYAN}" "${RC}"
    printf "\n"

    # Timezone - try to auto-detect first
    printf "\n"
    DETECTED_TZ=""
    if [ -f /etc/localtime ] && command -v readlink >/dev/null 2>&1; then
        DETECTED_TZ=$(readlink /etc/localtime 2>/dev/null | sed 's|.*/zoneinfo/||')
    fi
    if [ -z "$DETECTED_TZ" ] && [ -f /etc/timezone ]; then
        DETECTED_TZ=$(cat /etc/timezone 2>/dev/null)
    fi

    if [ -n "$DETECTED_TZ" ]; then
        printf "    %b󰥔%b  %bSystem detected your timezone to be '%s'%b\n" "${PURPLE}" "${RC}" "${WHITE}" "$DETECTED_TZ" "${RC}"
        printf "       %bIs this correct?%b %b[Y/n]%b: " "${WHITE}" "${RC}" "${DIM}" "${RC}"
        read -r tz_confirm
        case "$tz_confirm" in
            [Nn]*)
                select_timezone
                ;;
            *)
                TIMEZONE="$DETECTED_TZ"
                ok "Timezone set to: $TIMEZONE"
                ;;
        esac
    else
        printf "    %b󰥔%b  %bTimezone%b %b[Default: %s]%b\n" "${PURPLE}" "${RC}" "${WHITE}" "${RC}" "${DIM}${CYAN}" "$TIMEZONE" "${RC}"
        select_timezone
    fi

    # Locale selection
    printf "\n"
    printf "    %b󰗊%b  %bLocale%b %b[Default: %s]%b\n" "${PURPLE}" "${RC}" "${WHITE}" "${RC}" "${DIM}${CYAN}" "$LOCALE" "${RC}"
    printf "\n"
    printf "      %b1%b) %ben_US.UTF-8%b       %b(English - US)%b\n" "${CYAN}${BOLD}" "${RC}" "${WHITE}" "${RC}" "${DIM}" "${RC}"
    printf "      %b2%b) %ben_GB.UTF-8%b       %b(English - UK)%b\n" "${CYAN}${BOLD}" "${RC}" "${WHITE}" "${RC}" "${DIM}" "${RC}"
    printf "      %b3%b) %bde_DE.UTF-8%b       %b(German)%b\n" "${CYAN}${BOLD}" "${RC}" "${WHITE}" "${RC}" "${DIM}" "${RC}"
    printf "      %b4%b) %bfr_FR.UTF-8%b       %b(French)%b\n" "${CYAN}${BOLD}" "${RC}" "${WHITE}" "${RC}" "${DIM}" "${RC}"
    printf "      %b5%b) %bes_ES.UTF-8%b       %b(Spanish)%b\n" "${CYAN}${BOLD}" "${RC}" "${WHITE}" "${RC}" "${DIM}" "${RC}"
    printf "      %b6%b) %bShow all available...%b\n" "${YELLOW}${BOLD}" "${RC}" "${YELLOW}" "${RC}"
    printf "\n       %b➜%b " "${CYAN}" "${RC}"
    read -r locale_choice

    case "$locale_choice" in
        1) LOCALE="en_US.UTF-8" ;;
        2) LOCALE="en_GB.UTF-8" ;;
        3) LOCALE="de_DE.UTF-8" ;;
        4) LOCALE="fr_FR.UTF-8" ;;
        5) LOCALE="es_ES.UTF-8" ;;
        6)
            select_locale
            ;;
        *) LOCALE="en_US.UTF-8" ;;
    esac

    # Keyboard layout selection
    printf "\n"
    printf "    %b󰌌%b  %bKeyboard Layout%b %b[Default: %s]%b\n" "${PURPLE}" "${RC}" "${WHITE}" "${RC}" "${DIM}${CYAN}" "$KEYMAP" "${RC}"
    printf "\n"
    printf "      %b1%b) %bus%b      %b(US English)%b\n" "${CYAN}${BOLD}" "${RC}" "${WHITE}" "${RC}" "${DIM}" "${RC}"
    printf "      %b2%b) %buk%b      %b(UK English)%b\n" "${CYAN}${BOLD}" "${RC}" "${WHITE}" "${RC}" "${DIM}" "${RC}"
    printf "      %b3%b) %bde%b      %b(German)%b\n" "${CYAN}${BOLD}" "${RC}" "${WHITE}" "${RC}" "${DIM}" "${RC}"
    printf "      %b4%b) %bShow all available...%b\n" "${YELLOW}${BOLD}" "${RC}" "${YELLOW}" "${RC}"
    printf "\n       %b➜%b " "${CYAN}" "${RC}"
    read -r keymap_choice

    case "$keymap_choice" in
        1) KEYMAP="us" ;;
        2) KEYMAP="uk" ;;
        3) KEYMAP="de" ;;
        4)
            select_keymap
            ;;
        *) KEYMAP="us" ;;
    esac

    # Export variables
    export S4D_TIMEZONE="$TIMEZONE"
    export S4D_LOCALE="$LOCALE"
    export S4D_KEYMAP="$KEYMAP"

    printf "\n"
    ok "Configuration saved!"
    sleep 1
}
