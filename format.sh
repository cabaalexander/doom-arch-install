#!/bin/bash

set -e

. ./.env

if [[ "$EFI" ]]
then
  . ./utils/fdisk-efi.sh
else
  . ./utils/fdisk-efi-no.sh
fi

# Format HDD(s)
# =============
mkswap /dev/${SD}2

mkfs.ext4 /dev/${SD}3

mkfs.ext4 /dev/${SD}4

# Mount HDD(s)
# ============
swapon /dev/${SD}2

mount /dev/${SD}3 /mnt

mkdir -p /mnt/boot
mount /dev/${SD}1 /mnt/boot

mkdir -p /mnt/home
mount /dev/${SD}4 /mnt/home

lsblk

