#!/bin/bash

set -e

trap "{ clear; }" SIGINT SIGTERM EXIT

BRANCH=${1:-master}
REPO_RAW="https://gitlab.com/cabaalexander/doom-arch-install/raw/$BRANCH"

__get_repo_executable(){
  local FILE=$1
  local DEST=${2:-$FILE}

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

timedatectl set-ntp true

__get_repo_executable prompt.sh
__get_repo_executable format.sh
__get_repo_executable pacstrap.sh
__get_repo_executable chroot.sh

./prompt.sh
__execute ./format.sh
__execute ./pacstrap.sh ./chroot.sh

umount -R /mnt
swapoff /dev/sda2

reboot

