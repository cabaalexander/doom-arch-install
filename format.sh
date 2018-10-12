#!/bin/bash

set -e

. ./.env

if ls /sys/firmware/efi/efivars &> /dev/null
then
  . ./utils/fdisk-efi.sh
else
  . ./utils/fdisk-efi-no.sh
fi

# Swap on
# =======
mkswap /dev/${SD}2
swapon /dev/${SD}2

# Format HDD(s)
# =============
mkfs.ext4 /dev/${SD}3
mkfs.ext4 /dev/${SD}4

# Mount HDD(s)
# ============
mount /dev/${SD}3 /mnt

mkdir -p /mnt/home
mount /dev/${SD}4 /mnt/home

lsblk

