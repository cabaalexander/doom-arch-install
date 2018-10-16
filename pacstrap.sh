#!/bin/bash

set -e

. ./.env

pacstrap /mnt base base-devel vim
genfstab -U /mnt >> /mnt/etc/fstab

