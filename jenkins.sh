#!/bin/bash
if [-f /usr/local/bin/java.*]
then
	ver =$(java -version)
	echo "java exists"
else
	echo "java not found"
	sudo yum -y install java-1.8.0*-openjdk
fi
sudo yum -y install git
sudo yum -y install wget
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
sudo yum -y install jenkins
sudo systemctl enable jenkins
sudo systemctl start jenkins
sudo systemctl status jenkins
