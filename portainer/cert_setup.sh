#!/bin/bash
#Auto certificate setup for docker

set -e
# Any subsequent(*) commands which fail will cause the shell script to exit immediately

#Genrerate certificates
curl -LO https://raw.githubusercontent.com/Romromraisin/DockerToolbox/master/portainer/gen_cert.sh
bash gen_cert.sh

#Move clients certificates
mkdir -pvm 410 ~/docker
cp ca.pem ~/docker/ca.pem 
mv -f client.pem ~/docker/client.pem 
mv -f clientkey.pem ~/docker/clientkey.pem
chmod -R 410 ~/docker

#Move server certificates
mv -f {server.pem,serverkey.pem,ca.pem} /etc/docker/
chown root:root /etc/docker/{serverkey.pem,server.pem,ca.pem}
chmod 0600 /etc/docker/serverkey.pem

# Get your clients certificate in /root/docker

<<COMMENT
#WITH SYSTEMD (recommended)
vi /lib/systemd/system/docker.service
#https://docs.docker.com/install/linux/linux-postinstall/#configuring-remote-access-with-systemd-unit-file

ExecStart=/usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock \
  --tls=true \
  --tlscacert="/etc/docker/ca.pem" \
  --tlscert="/etc/docker/server.pem" \
  --tlskey="/etc/docker/serverkey.pem" \
  --host tcp://0.0.0.0:2376

#WITHOUT SYSTEMD
vi /etc/docker/daemon.json
#Config file https://docs.docker.com/engine/reference/commandline/dockerd/#daemon-configuration-file
{
  "tls": true,
  "tlscacert": "/etc/docker/ca.pem",
  "tlscert": "/etc/docker/server.pem",
  "tlskey": "/etc/docker/serverkey.pem",
  "hosts": ["tcp://0.0.0.0:2376"]
}
COMMENT

#Replace line to start docker with remote API enables on  port 2376
sed -i 's/ExecStart=.*/ExecStart=\/usr\/bin\/dockerd -H fd:\/\/ --containerd=\/run\/containerd\/containerd.sock --tls=true --tlscacert="\/etc\/docker\/ca.pem" --tlscert="\/etc\/docker\/server.pem" --tlskey="\/etc\/docker\/serverkey.pem" --host tcp:\/\/0.0.0.0:2376/' /usr/lib/systemd/system/docker.service

#Apply settings
systemctl daemon-reload
systemctl restart docker.service

#Firewall firewalld issue for centos, not working in ipv4 by default
firewall-cmd --add-port=2376/tcp --permanent
firewall-cmd --reload
systemctl restart docker.service

