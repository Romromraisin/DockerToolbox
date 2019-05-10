#!/bin/bash
#Install docker-ce
#sudo bash install.sh "ubuntu"

set -e
# Any subsequent(*) commands which fail will cause the shell script to exit immediately

#PARAMETERS
#Pick a distribution
#Supported : centos; ubuntu
DISTRO=$1

#UBUNTU
if [ "$DISTRO" == "ubuntu" ]; then
	#Install prerequisits
	apt update
	apt install apt-transport-https ca-certificates curl software-properties-common -y
	#Add Docker Repo
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
	add-apt-repository "https://download.docker.com/linux/ubuntu stable"
	#Install Docker CE
	apt update
	apt install docker-ce -y
	#Start Docker at boot
	systemctl enable docker

#CENTOS	
elif [ "$DISTRO" == "centos" ]; then
	yum install -y yum-utils device-mapper-persistent-data lvm2
	yum-config-manager -y --add-repo https://download.docker.com/linux/centos/docker-ce.repo
	yum install -y docker-ce docker-ce-cli containerd.io
	systemctl start docker
	#Start Docker at boot
	systemctl enable docker
	
else
    echo Unknown distro

fi
