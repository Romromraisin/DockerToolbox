#!/bin/bash
#Install docker-ce
#sudo bash install.sh "ubuntu"

#PARAMETERS
#Pick a distribution
#Supported : centos; ubuntu
$DISTRO=$1

#UBUNTU
if [ $DISTRO -eq "ubuntu" ]; then
	#Install prerequisits
	apt update
	apt install apt-transport-https ca-certificates curl software-properties-common -y
	#Add Docker Repo
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
	add-apt-repository "https://download.docker.com/linux/ubuntu stable"
	#Install Docker CE
	apt update
	apt install docker-ce -y

#CENTOS	
elif [ $DISTRO -eq "centos" ]; then
	yum install -y yum-utils device-mapper-persistent-data lvm2
	yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
	yum install docker-ce docker-ce-cli containerd.io
	systemctl start docker

else
    echo Unknown distro

fi
