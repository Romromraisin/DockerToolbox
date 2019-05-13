#!/bin/bash
#Install a docker registry on CentOS 7 docker host
#Get your clients certs in /certs

set -e
# Any subsequent(*) commands which fail will cause the shell script to exit immediately

#PARAMETERS
#Registry docker host IP
IP=$1

USERNAME=registry

#Install base packages
yum install \
    ca-certificates \
    curl	

#Edit OpenSSL config file to add host IP
#/etc/pki/tls/openssl.cnf on CentOS
# After this line
#[ v3_ca ]
# Add this line, Change IP by register host IP
#subjectAltName=IP:10.2.15.10
sed -i.bak "/\[ v3_ca \]/a subjectAltName=IP:$IP" /etc/pki/tls/openssl.cnf

#Gen certs and store them locally
mkdir -p /certs
openssl req \
  -newkey rsa:4096 -nodes -sha256 -keyout /certs/domain.key \
  -x509 -days 3650 -out /certs/domain.crt

#Add certificates to docker trusted certificates
mkdir -p /etc/docker/certs.d/$IP:5000
cp -f /certs/domain.key /etc/docker/certs.d/$IP:5000/ca.key
cp -f /certs/domain.crt /etc/docker/certs.d/$IP:5000/ca.crt
cp -f /certs/domain.crt /etc/docker/certs.d/$IP:5000/ca.cert
chmod -R 750 /etc/docker/certs.d

#reload docker daemon to use the certificate
service docker reload

#TEST ME
#docker pull 10.2.15.10:5000/busybox

#Setting up authentification
#Random password
PASSWORD=$(/bin/openssl rand -base64 32)
mkdir /auth
#Generate password file
docker run \
  --name DeleteMe-Gen-registry-password \
  --entrypoint htpasswd \
  registry:2 -Bbn $USERNAME $PASSWORD > /auth/htpasswd
#Protect password
chmod -R 750 /auth

docker rm --force DeleteMe-Gen-registry-password

#Create volume
docker volume create registry_data

#Start registry with certificates and basic auth
docker run -d \
  -p 5000:5000 \
  --restart=always \
  --name registry \
  -v /auth:/auth \
  -e "REGISTRY_AUTH=htpasswd" \
  -e "REGISTRY_AUTH_HTPASSWD_REALM=Registry Realm" \
  -e REGISTRY_AUTH_HTPASSWD_PATH=/auth/htpasswd \
  -v /certs:/certs \
  -v registry_data:/var/lib/registry \
  -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/domain.crt \
  -e REGISTRY_HTTP_TLS_KEY=/certs/domain.key \
  registry:2
  
  echo "credentilals : "
  echo "username : " $USERNAME
  echo "Password : " $PASSWORD
