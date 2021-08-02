#!/bin/bash

if [ -f /etc/yum.repos.d/docker-ce.repo ]
then 
  ver=$(docker-version)
  echo"Docker exists"
else
  echo "docker not found"
  sudo yum install -y yum-utils
  sudo yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo
    sudo yum -y install docker-ce
fi
