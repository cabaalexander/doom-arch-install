#!/bin/bash

ARCH_CHROOT_INSTALL="doom-chroot-install.sh"
SD=$(< /tmp/doom-sd)
ROOT_PSSWD=$(< /tmp/doom-root-psswd)

cat <<EOF > /mnt/$ARCH_CHROOT_INSTALL
#!/bin/bash

yes | pacman --needed -S networkmanager
yes | pacman --needed -S grub

systemctl enable NetworkManager

grub-install --target=i386-pc /dev/${SD}
grub-mkconfig -o /boot/grub/grub.cfg

echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
echo "en_US ISO-8859-1" >> /etc/locale.gen
locale-gen

ln -sf /usr/share/zoneinfo/America/Santo_Domingo /etc/localtime
hwclock -w

echo "root:${ROOT_PSSWD}" | chpasswd

rm ./$ARCH_CHROOT_INSTALL
EOF

chmod u+x /mnt/$ARCH_CHROOT_INSTALL

arch-chroot /mnt ./$ARCH_CHROOT_INSTALL
