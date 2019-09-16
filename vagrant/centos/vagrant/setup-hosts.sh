#!/bin/bash
set -e
IFNAME=$1
ADDRESS="$(ip -4 addr show $IFNAME | grep "inet" | head -1 |awk '{print $2}' | cut -d/ -f1)"
sed -e "s/^.*${HOSTNAME}.*/${ADDRESS} ${HOSTNAME} ${HOSTNAME}.local/" -i /etc/hosts


# Update /etc/hosts about other hosts
cat >> /etc/hosts <<EOF
192.168.25.11  master-1
192.168.25.12  master-2
192.168.25.21  worker-1
192.168.25.22  worker-2
192.168.25.30  lb
EOF
