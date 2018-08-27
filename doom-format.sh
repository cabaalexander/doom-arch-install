#!/bin/bash

inputBox(){
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

# Dialog
inputBox "Hard drive path" /tmp/doom-sd "sda"
inputBox "Swap space (GB)" /tmp/doom-swap "1"
inputBox "Root space (GB)" /tmp/doom-root "4"
inputBox "Hostname" /tmp/doom-hostname "archion-pc"
inputBox -p "Root password" /tmp/doom-root-psswd "welc0me"

# Variables
SWAP=$(< /tmp/doom-swap)
ROOT=$(< /tmp/doom-root)
SD=$(< /tmp/doom-sd)
HOSTNAME=$(< /tmp/doom-hostname)

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

