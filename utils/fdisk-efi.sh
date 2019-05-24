#!/bin/bash
set -Eeuo pipefail

fdisk /dev/"${SD:-}" <<EOF
g
n


+512M
n


+${SWAP:-}G
n


+${ROOT:-}G
n



t
1
1
t
2
19
t
3
24
t
4
28
w
EOF

mkfs.fat -F32 /dev/"${SD:-}"1

