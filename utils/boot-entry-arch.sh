cat <<EOF
cat <<BOOT_EOF >> /boot/loader/entries/arch.conf
title Arch Linux
linux vmlinuz-linux
initrd /intel-ucode.img
initrd /initramfs-linux.img
options root=UUID=$(blkid -s UUID -o value /dev/sda3) rw
BOOT_EOF
EOF

