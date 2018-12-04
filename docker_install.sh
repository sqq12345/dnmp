#!/bin/bash
# by skywalkerwei 2018.12.03
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
LANG=en_US.UTF-8
yum -y update
curl -fsSL get.docker.com -o get-docker.sh
sudo sh get-docker.sh --mirror Aliyun
systemctl enable docker
systemctl start docker
yum -y install epel-release
yum -y install python-pip
pip install docker-compose --ignore-installed requests