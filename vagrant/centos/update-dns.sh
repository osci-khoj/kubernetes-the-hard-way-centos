#!/bin/bash

sed -i -e 's/nameserver.*/nameserver 8.8.8.8/' /etc/resolv.conf
