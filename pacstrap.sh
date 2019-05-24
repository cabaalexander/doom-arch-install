#!/bin/bash
set -Eeuo pipefail

pacstrap /mnt \
    base \
    base-devel \
    vim \
    grml-zsh-config

genfstab -U /mnt >> /mnt/etc/fstab

