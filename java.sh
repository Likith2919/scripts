#!/bin/bash
if [-f /usr/local/bin/java.*]
then
	ver =$(java -version)
	echo "java exists"
else
	echo "java not found"
	sudo yum -y install java-1.8.0*-openjdk
