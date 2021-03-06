#!/bin/bash
#Install a portainer container on local host and connect with socket

set -e
# Any subsequent(*) commands which fail will cause the shell script to exit immediately

#Create volume for persistant data
docker volume create portainer_data
#Run container
docker run -d -p 9000:9000 --name portainer --restart always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer