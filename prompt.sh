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
  local FD_FILE=$2
  local DEFAULT_VALUE=$3
  local HEIGHT=${4:-"0"}

  whiptail $TYPE \
    --title "Doom arch-linux" \
    --ok-button "Continue" \
    --cancel-button "Exit" \
    "\n$MESSAGE" \
    $((10 + $HEIGHT)) 40 \
    "$DEFAULT_VALUE" 2> $FD_FILE || exit
}

__save_var(){
  [ -f ./.env ] || touch ./.env
  local KEY_VALUE="$1=$2"
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

__input_box "$SD_MESSAGE" ${BASE_DIST}-sd "sda" $SD_OPTIONS_HEIGHT
__save_var "SD" $(< ${BASE_DIST}-sd)

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

__input_box "$SWAP_MESSAGE" ${BASE_DIST}-swap "1" 1
__save_var "SWAP" $(< ${BASE_DIST}-swap)
__sd_size_acc $SWAP

########
#      #
# ROOT #
#      #
########
SD_SIZE="$(__sd_size $SD)"
SD_SEVENTY_FIVE_PERCENT=$(__awk_math "($SD_SIZE - $SWAP) * 0.75")

__input_box "Root space (GB)" ${BASE_DIST}-root "$SD_SEVENTY_FIVE_PERCENT"
__save_var "ROOT" $(< ${BASE_DIST}-root)
__sd_size_acc $ROOT

########
#      #
# HOME #
#      #
########
SD_SEVENTY_FIVE_PERCENT=$(__awk_math "$SD_SIZE - $SD_SIZE_ACC")

__input_box "Home space (GB)" ${BASE_DIST}-home "$SD_SEVENTY_FIVE_PERCENT"
__save_var "HOME" $(< ${BASE_DIST}-home)

############
#          #
# HOSTNAME #
#          #
############
__input_box "Hostname" ${BASE_DIST}-hostname "archlinux"
__save_var "HOSTNAME" $(< ${BASE_DIST}-hostname)

#################
#               #
# ROOT PASSWORD #
#               #
#################
__input_box -p "Root password" ${BASE_DIST}-root-psswd "welc0me"
__save_var "ROOT_PSSWD" $(< ${BASE_DIST}-root-psswd)

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
  && __save_var "EFI" 0

# Export all variable
# ===================
sed -i 's/^/export /' ./.env

__input_box "$SURE_MSG" ${BASE_DIST}-Q "y" $SURE_OPTIONS_HEIGHT
[[ "$(< $BASE_DIST-Q)" =~ ^[yY][eE]?[sS]?$ ]] || {
  SCRIPT_BASENAME=$(basename ${0})
  echo "You did not press \`y\`" > ${SCRIPT_BASENAME%.*}.log
  exit 1
}

