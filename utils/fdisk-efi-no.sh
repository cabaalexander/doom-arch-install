#!/bin/bash

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

mkdir -p /mnt/boot
mount /dev/${SD}1 /mnt/boot

