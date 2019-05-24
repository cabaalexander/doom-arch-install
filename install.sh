#!/bin/bash
set -Eeuo pipefail

# install my arch rice (raise ? / version)

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BRANCH=${1:-master}
REPO_RAW="https://raw.githubusercontent.com/cabaalexander/doom-arch-install/$BRANCH"
DOWNLOAD_FILES="$CURRENT_DIR"

get_repo_executable(){
    local file file_in_repo local_file_dir_path downloaded_file

    file=$1
    file_in_repo="$REPO_RAW/$file"
    local_file_dir_path=$(dirname "$1")
    downloaded_file="$DOWNLOAD_FILES/$file"

    mkdir -p "$DOWNLOAD_FILES/$local_file_dir_path"

    echo "Fetching '$file'"

    curl -s "$file_in_repo" > "$downloaded_file"
    chmod u+x "$downloaded_file"
}

# Gather needed required files
# ============================
while read -rs file
do
    [ -f "$file" ] && continue
    get_repo_executable "$file"
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

"$DOWNLOAD_FILES/prompt.sh"
"$DOWNLOAD_FILES/format.sh"
"$DOWNLOAD_FILES/pacstrap.sh"
"$DOWNLOAD_FILES/chroot.sh"

umount -R /mnt
swapoff /dev/sda2

reboot

