#!/bin/bash

set -e

__sd_size(){
  local SD=${1:-"sda"}
  lsblk \
    | egrep "^$SD.*$" \
    | awk -F' ' '{print $4}' \
    | tr -d "[[:alpha:]]"
}

__input_box(){
  if [ "$1" == "-p" ]
  then
    local TYPE="--passwordbox"
    shift
  else
    local TYPE="--inputbox"
  fi

  local MESSAGE=$1
  local DEFAULT_VALUE=$2
  local HEIGHT=${3:-"0"}

  local FD_FILE=${BASE_DIST}-reply

  whiptail $TYPE \
    --title "Doom arch-linux" \
    --ok-button "Continue" \
    --cancel-button "Exit" \
    "\n$MESSAGE" \
    $((10 + $HEIGHT)) 40 \
    "$DEFAULT_VALUE" 2> $FD_FILE || exit
}

__save_reply(){
  [ -f ./.env ] || touch ./.env
  local KEY=$1

  if [[ "$2" ]]
  then
    local VALUE=$2
  else
    local VALUE=$(< ${BASE_DIST}-reply)
  fi

  local KEY_VALUE="$KEY=$VALUE"

  eval "$KEY_VALUE"

  echo "$KEY_VALUE" >> ./.env
}

__awk_math(){
  [ $# -gt 1 ] && exit 0
  eval "awk -F' ' '{printf \"%.0f\",($1)}' <<<\"NULL\""
}

__sd_size_acc(){
  SD_SIZE_ACC=$(__awk_math "$SD_SIZE_ACC + $1")
}

# Clean ./.env
rm -f ./.env

# Prefix for generated files
# ==========================
BASE_NAME=$(basename $0)
BASE_DIST=/tmp/doom-${BASE_NAME%.*}

#######
#     #
# SD* #
#     #
#######
SD_AVAILABLE=$(lsblk | egrep "^sd.*$" | awk -F' ' '{printf "• %s %s:",$1,$4}')
SD_OPTIONS_HEIGHT=$(grep -o : <<<$"$SD_AVAILABLE" | wc -l)
SD_MESSAGE="Available hard drives (Choose)\n\n$(tr ':' '\n' <<<$SD_AVAILABLE)"

__input_box "$SD_MESSAGE" "sda" $SD_OPTIONS_HEIGHT
__save_reply "SD"

########
#      #
# SWAP #
#      #
########
RECOMMENDED_SWAP_SPACE=$(
  free -m \
    | egrep "^Mem:" \
    | awk -F' ' '{printf "%.0f",($2 * 2 / 1024)"G"}'
)
SWAP_MESSAGE="Swap space (GB)\n\nRecommended: $RECOMMENDED_SWAP_SPACE"

__input_box "$SWAP_MESSAGE" "1" 1
__save_reply "SWAP"
__sd_size_acc $SWAP

########
#      #
# ROOT #
#      #
########
SD_SIZE="$(__sd_size $SD)"
SD_SEVENTY_FIVE_PERCENT=$(__awk_math "($SD_SIZE - $SWAP) * 0.75")

__input_box "Root space (GB)" "$SD_SEVENTY_FIVE_PERCENT"
__save_reply "ROOT"
__sd_size_acc $ROOT

########
#      #
# HOME #
#      #
########
SD_SPACE_LEFT=$(__awk_math "$SD_SIZE - $SD_SIZE_ACC")

__input_box "Home space (GB)" "$SD_SPACE_LEFT"
__save_reply "HOME"

############
#          #
# HOSTNAME #
#          #
############
__input_box "Hostname" "archlinux"
__save_reply "HOSTNAME"

#################
#               #
# ROOT PASSWORD #
#               #
#################
__input_box -p "Root password" "welc0me"
__save_reply "ROOT_PSSWD"

############
#          #
# SURE (?) #
#          #
############
SURE_MSG="All sure? (y/n)\n\n$(cat ./.env)"
SURE_OPTIONS_HEIGHT=$(cat ./.env | wc -l)

# Save EFI variable if EFI-mode is on
# ===================================
ls /sys/firmware/efi/efivars &> /dev/null \
  && __save_reply "EFI" 0

# Export all variable
# ===================
sed -i 's/^/export /' ./.env

__input_box "$SURE_MSG" "y" $SURE_OPTIONS_HEIGHT
[[ "$(< $BASE_DIST-reply)" =~ ^[yY][eE]?[sS]?$ ]] || {
  SCRIPT_BASENAME=$(basename ${0})
  echo "You did not press \`y\`" > ${SCRIPT_BASENAME%.*}.log
  exit 1
}

