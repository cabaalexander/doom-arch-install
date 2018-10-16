#!/bin/bash

set -e

. ./.env

ARCH_CHROOT_INSTALL="chroot-install.sh"

cat <<ARCH_ROOT_EOF > /mnt/$ARCH_CHROOT_INSTALL
#!/bin/bash

pacman --needed --noconfirm -S \
  networkmanager \
  grub \
  efibootmgr \
  intel-ucode

# Wifi
pacman --needed --noconfirm -S \
  iw \
  wpa_supplicant \
  dialog

systemctl enable NetworkManager

$(./utils/etc-locale-gen.sh)

echo "LANG=en_US.UTF-8" > /etc/locale.conf

locale-gen

echo ${HOSTNAME} > /etc/hostname
$(./utils/etc-hosts.sh)

ln -sf /usr/share/zoneinfo/America/Santo_Domingo /etc/localtime
hwclock -w

if [[ "$EFI" ]]
then
  bootctl install
  $(./utils/boot-entry-arch.sh)
  $(./utils/boot-loader-conf.sh)
else
  grub-install --target=i386-pc /dev/${SD}
fi

grub-mkconfig -o /boot/grub/grub.cfg

echo "root:${ROOT_PSSWD}" | chpasswd

rm ./$ARCH_CHROOT_INSTALL
ARCH_ROOT_EOF

chmod u+x /mnt/$ARCH_CHROOT_INSTALL

arch-chroot /mnt ./$ARCH_CHROOT_INSTALL

