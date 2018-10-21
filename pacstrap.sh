#!/bin/bash

set -e

pacstrap /mnt \
	base \
	base-devel \
	vim \
	grml-zsh-config

genfstab -U /mnt >> /mnt/etc/fstab

