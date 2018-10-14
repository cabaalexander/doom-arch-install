cat <<EOF
cat <<HOSTS_EOF >> /etc/hosts
127.0.0.1   localhost.localdomain     localhost     ${HOSTNAME}
::1         localhost.localdomain     localhost     ${HOSTNAME}
127.0.1.1   ${HOSTNAME}.localdomain   ${HOSTNAME}
HOSTS_EOF
EOF

