#!/bin/bash
# by skywalkerwei 2018.12.03
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
LANG=en_US.UTF-

command_exists() {
	command -v "$@" > /dev/null 2>&1
}

do_install(){
	yum -y update

	if command_exists docker; then
		echo "docker 已安装"
	else
		curl -fsSL get.docker.com -o get-docker.sh
		sudo sh get-docker.sh --mirror Aliyun
		systemctl enable docker
		systemctl start docker
	fi

	if command_exists pip; then
		echo "pip 已安装"
	else
		yum -y install epel-release
		yum -y install python-pip
	fi

	if command_exists docker-compose; then
		echo "compose 已安装"
	else
		pip install docker-compose --ignore-installed requests	
	fi

}

do_install
