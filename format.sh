#!/bin/bash

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

  whiptail $TYPE \
    --title "Doom arch-linux" \
    --ok-button "Continue" \
    --cancel-button "Exit" \
    "\n$MESSAGE" \
    10 30 \
    "$DEFAULT_VALUE" 2> $FD_FILE || exit
}

# Dialog\Prompt
__input_box "Hard drive path" /tmp/doom-sd "sda"
SD=$(< /tmp/doom-sd)

__input_box "Swap space (GB)" /tmp/doom-swap "1"
SWAP=$(< /tmp/doom-swap)

SD_SIZE_LEFT=$(($(__sd_size $SD) - $SWAP))

__input_box "Root space (GB)" /tmp/doom-root "$SD_SIZE_LEFT"
ROOT=$(< /tmp/doom-root)

__input_box "Hostname" /tmp/doom-hostname "archlinux"
HOSTNAME=$(< /tmp/doom-hostname)

__input_box -p "Root password" /tmp/doom-root-psswd "welc0me"

read -p "All sure?" Q
[[ "Q" ]] || exit 0

fdisk /dev/${SD} <<EOF
o
n
p


+200M
n
p


+${SWAP}G
n
p


+${ROOT}G
n
p


w
EOF

partprobe | tee /tmp/partprobe.log

mkfs.ext4 /dev/${SD}1
mkfs.ext4 /dev/${SD}3
mkfs.ext4 /dev/${SD}4

mkswap /dev/${SD}2
swapon /dev/${SD}2

mount /dev/${SD}3 /mnt

mkdir /mnt/boot
mount /dev/${SD}1 /mnt/boot

mkdir /mnt/home
mount /dev/${SD}4 /mnt/home

pacstrap /mnt base base-devel vim
genfstab -U /mnt >> /mnt/etc/fstab

echo ${HOSTNAME} > /mnt/etc/hostname

