#!/bin/bash
CE_VERSION_STRING="19.03.2"
CLI_VERSION_STRING="19.03.2"

yum install -y yum-utils device-mapper-persistent-data lvm2
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo 
yum-config-manager --enable docker-ce-nightly
yum-config-manager --enable docker-ce-test
yum install -y docker-ce-$CE_VERSION_STRING docker-ce-cli-$CLI_VERSION_STRING containerd.io
systemctl start docker
