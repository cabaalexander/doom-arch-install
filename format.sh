#!/bin/bash

set -e

. ./.env

__not_efi(){
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


+${HOME}G
w
EOF

mkfs.ext4 /dev/${SD}1
}

__efi(){
fdisk /dev/${SD} <<EOF
g
n


+512M
n


+${SWAP}G
n


+${ROOT}G
n



t
1
1
t
2
19
t
3
24
t
4
28
w
EOF

mkfs.fat -F32 /dev/${SD}1
}

if ls /sys/firmware/efi/efivars &> /dev/null
then
  __efi
else
  __not_efi
fi

# Format HDD(s)
# =============
mkfs.ext4 /dev/${SD}3
mkfs.ext4 /dev/${SD}4

mkswap /dev/${SD}2
swapon /dev/${SD}2

# Mount HDD(s)
# ============
mount /dev/${SD}3 /mnt

mkdir -p /mnt/boot
mount /dev/${SD}1 /mnt/boot

mkdir -p /mnt/home
mount /dev/${SD}4 /mnt/home

lsblk

