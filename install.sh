#!/bin/bash

set -e

BRANCH=${1:-master}
REPO_RAW="https://gitlab.com/cabaalexander/doom-arch-install/raw/$BRANCH"

__get_repo_executable(){
  local FILE=$1
  local DEST=./${2:-$FILE}
  local DEST_DIRPATH=${DEST%/*}

  mkdir -p $DEST_DIRPATH

  echo "Fetching ${REPO_RAW%/raw*}/$FILE..."

  curl -s ${REPO_RAW}/$FILE > $DEST
  chmod u+x $DEST
}

__execute(){
  local FILES=($@)

  ARGS_LENGTH=$(wc -w <<<"${FILES[*]}")
  [ $ARGS_LENGTH -gt 0 ] || return 0

  local FILE=${FILES[0]}
  local BASENAME=$(basename $FILE)
  local LOG="${BASENAME%.*}.log"

  $FILE | tee $LOG

  # Begin recursion
  shift
  FILES=($@)
  __execute ${FILES[*]}
}

# Gather needed required files
# ============================
while read -rs FILE
do
  __get_repo_executable $FILE
done <<EOF
  prompt.sh
  format.sh
  pacstrap.sh
  chroot.sh
  utils/fdisk-efi.sh
  utils/fdisk-efi-no.sh
  utils/etc-hosts.sh
  utils/etc-locale-gen.sh
  utils/boot-entry-arch.sh
  utils/boot-loader-conf.sh
EOF

./prompt.sh
__execute ./format.sh
__execute ./pacstrap.sh
__execute ./chroot.sh

umount -R /mnt
swapoff /dev/sda2

reboot

