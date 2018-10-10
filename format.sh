#!/bin/bash

set -e

. ./.env

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

lsblk

