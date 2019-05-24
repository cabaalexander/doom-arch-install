#!/bin/bash
set -Eeuo pipefail

# install 'dialog' (required)
if ! command -v dialog &> /dev/null; then
    sudo pacman --needed --noconfirm -S dialog &> /dev/null
fi

# Prefix for generated files
# ==========================
DOOM_PROMPT_REPLY=$(mktemp)
trap '{ rm -rf "$DOOM_PROMPT_REPLY" ; }' SIGINT SIGTERM EXIT

sd_size(){
    local sd
    sd=${1:-"sda"}
    lsblk |
        awk "/^$sd/ {print \$4}" |
        tr -d '[:alpha:]'
}

input_box(){
    local OPT message default_value height input_type

    while getopts ":p" OPT; do
        case $OPT in
            p) input_type="--passwordbox" ;;
            *) # do default stuff ;;
        esac
    done
    shift $((OPTIND - 1))

    message=${1:-dialog box}
    default_value=${2:-}
    height=${3:-"0"}

    dialog --title "Doom arch-linux" \
        --ok-button "Continue" \
        --cancel-button "Exit" \
        ${input_type:-"--inputbox"} \
        "$message" \
        $((9 + height)) 80 \
        "$default_value" \
        2> "$DOOM_PROMPT_REPLY"
}

save_reply(){
    # Set the replay to the key you pass and also save it to the '.env' file
    local KEY VALUE KEY_EQUALS_VALUE

    KEY=$1
    VALUE=${2:-$(<"$DOOM_PROMPT_REPLY")}

    touch ./.env

    KEY_EQUALS_VALUE="$KEY=$VALUE"

    eval "$KEY_EQUALS_VALUE"

    echo "$KEY_EQUALS_VALUE" >> ./.env
}

awk_math(){
    [ $# -gt 1 ] && exit 0
    awk "BEGIN {printf \"%.0f\",($1)}"
}

sd_size_acc(){
    # this adds up the space taken by the new hard drives
    SD_SIZE_ACC=$(awk_math "${SD_SIZE_ACC:-0} + $1")
}

#########
#       #
# Begin #
#       #
#########

# Clean ./.env
rm -f ./.env

#######
#     #
# sd* #
#     #
#######
sd_available=$(lsblk | grep -E "^sd.*$" | awk '{printf "• %s %s:",$1,$4}')
sd_available_height=$(grep -o : <<<$"$sd_available" | wc -l)
sd_message="Available hard drives (Choose)\n\n$(tr ':' '\n' <<<"$sd_available")"

input_box "$sd_message" "sda" "$sd_available_height"
save_reply "SD"

########
#      #
# SWAP #
#      #
########
recommended_swap_space=$(
  free -m \
    | grep -E "^Mem:" \
    | awk -F' ' '{printf "%.0f",($2 * 2 / 1024)"G"}'
)
swap_message="Swap space (GB)\n\nRecommended: $recommended_swap_space"

input_box "$swap_message" "1" "1"
save_reply "SWAP"
sd_size_acc "$SWAP"

########
#      #
# ROOT #
#      #
########
sd_size="$(sd_size "$SD")"
sd_seventy_five_percent=$(awk_math "($sd_size - $SWAP) * 0.75")

input_box "Root space (GB)" "$sd_seventy_five_percent"
save_reply "ROOT"
sd_size_acc "${ROOT:-}"

########
#      #
# HOME #
#      #
########
sd_space_left=$(awk_math "$sd_size - $SD_SIZE_ACC")

input_box "Home space (GB)" "$sd_space_left"
save_reply "HOME"

############
#          #
# HOSTNAME #
#          #
############
input_box "Hostname" "archlinux"
save_reply "HOSTNAME"

#################
#               #
# ROOT PASSWORD #
#               #
#################
# input_box -p "Root password" "welc0me"
input_box "Root password" "welc0me"
save_reply "ROOT_PSSWD"

############
#          #
# SURE (?) #
#          #
############
sure_msg="All sure? (y/n)\n\n$(<.env)"
sure_options_height=$(awk 'END {print NR}' ./.env)

# Save EFI variable if EFI-mode is on
# ===================================
ls /sys/firmware/efi/efivars &> /dev/null \
  && save_reply "EFI" 0

# Export all variable in `.env` file
# so that the other scripts can use them
# ===================
sed -i 's/^/export /' ./.env

input_box "$sure_msg" "y" "$sure_options_height"

[[ "$(<"$DOOM_PROMPT_REPLY")" =~ ^[yY][eE]?[sS]?$ ]] || exit 1

