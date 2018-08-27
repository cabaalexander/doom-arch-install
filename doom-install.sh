#!/bin/bash

BRANCH=${1:-master}
REPO_RAW="https://gitlab.com/cabaalexander/doom-arch-install/raw/$BRANCH"

getRepoExecutable(){
  local FILE=$1
  local DEST=${2:-$FILE}

  curl -s ${REPO_RAW}/$FILE > $DEST
  chmod u+x $DEST
}

getRepoExecutable doom-format.sh
getRepoExecutable doom-chroot.sh

./doom-format.sh
./doom-chroot.sh

reboot

