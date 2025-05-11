#!/bin/ash

HOSTNAME=$(hostname)
UPLOAD_DIR="/home/vagrant/uploads"
SSH_KEY="/home/vagrant/.ssh/sftp_key"
SFTP_USER="vagrant"
NEIGHBORS=$(cat /home/vagrant/neighbors.conf)

# Create timestamp
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
TMP_FILE=$(mktemp)
echo "$TIMESTAMP $HOSTNAME" > "$TMP_FILE"

# Upload to neighbors
for IP in $NEIGHBORS; do
  sftp -i "$SSH_KEY" \
       -o StrictHostKeyChecking=no \
       -o UserKnownHostsFile=/dev/null \
       "${SFTP_USER}@${IP}" <<EOF
put "$TMP_FILE" "${UPLOAD_DIR}/${HOSTNAME}_$(date +%s).log"
EOF
done

# Cleanup
rm -f "$TMP_FILE"