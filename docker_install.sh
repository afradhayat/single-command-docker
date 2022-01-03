#!/bin/bash 
echo " #yum dependency solve for docker# "
yum install -y vim yum-utils device-mapper-persistent-data lvm2 

echo " # enable docker repo # "
yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo

echo "# docker-install #"
yum install -y docker-ce docker-ce-cli containerd.io 
[ ! -d /etc/docker ] && mkdir /etc/docker
echo "Set SELinux in permissive mode (effectively disabling it)"
setenforce 0 
sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config 

echo "######################daemon Create############################"
touch /etc/docker/daemon.json 
tee /etc/docker/daemon.json <<EOT 
{
   "experimental":true,
   "insecure-registries" : ["192.168.1.140:5000"],
   "log-driver": "json-file",
   "log-opts": { "max-size": "10m", "max-file": "3" }
}
EOT

echo "#disable firewalld#"
systemctl disable --now firewalld

echo "#docker-daemon reload#"
systemctl daemon-reload

echo "# start docker engine#"
systemctl start docker 

echo "#enable docker service for boot up#"
systemctl enable docker.service

echo "# status of docker engine #"
systemctl status docker



