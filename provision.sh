#!/bin/bash

# set hostname and private ip address
hostnamectl set-hostname master
IP=$(ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1  -d'/')
echo "$IP master.hadoop.lan master" | sudo tee -a /etc/hosts > /dev/null
# TODO add hook for eth0 up in addition?

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

# Hadoop
sudo chmod +x /vagrant/hadoop/hadoop.sh
/vagrant/hadoop/hadoop.sh

