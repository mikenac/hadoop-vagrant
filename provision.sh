#!/bin/bash

# this will register with RHEL network
sudo chmod +x /vagrant/register.sh
/vagrant/register.sh

# update the system
sudo yum -y update

# install Oracle Java 8
echo "Installing Oracle Java 8"
sudo yum -y install java-1.8.0-oracle-devel.x86_64
echo "JAVA_HOME=/usr/lib/jvm/java" | sudo tee -a /etc/environment > /dev/null
source /etc/environment

echo "Base provisioning complete."

