#!/bin/bash

set -e

trap "{ clear; }" SIGINT SIGTERM EXIT

BRANCH=${1:-master}
REPO_RAW="https://gitlab.com/cabaalexander/doom-arch-install/raw/$BRANCH"

getRepoExecutable(){
  local FILE=$1
  local DEST=${2:-$FILE}

  curl -s ${REPO_RAW}/$FILE > $DEST
  chmod u+x $DEST
}

getRepoExecutable format.sh
getRepoExecutable chroot.sh

./format.sh
./chroot.sh

reboot

