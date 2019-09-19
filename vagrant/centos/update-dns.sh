#!/bin/bash

sed -i -e 's/nameserver.*/nameserver 8.8.8.8/' /etc/resolv.conf
#yum install -y systemd-resolved
#sudo systemctl enable systemd-resolved
#sudo systemctl start systemd-resolved
yum install -y wget
