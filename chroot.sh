#!/bin/bash

set -e

. ./.env

ARCH_CHROOT_INSTALL="chroot-install.sh"

cat <<EOF > /mnt/$ARCH_CHROOT_INSTALL
#!/bin/bash

pacman --needed --noconfirm -S networkmanager
pacman --needed --noconfirm -S grub
pacman --needed --noconfirm -S efibootmgr

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

