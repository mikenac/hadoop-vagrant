#!/bin/bash

HADOOP_VERSION=2.7.3
HADOOP_FILE=hadoop-$HADOOP_VERSION.tar.gz
HADOOP_URL=http://apache.mirrors.pair.com/hadoop/common/hadoop-$HADOOP_VERSION/$HADOOP_FILE
RES_DIR=/vagrant/resources
HADOOP_HOME=/opt/hadoop

echo "Installing Hadoop"
sudo mkdir -p $HADOOP_HOME
sudo chmod 775 $HADOOP_HOME

# add the user for hdfs
sudo useradd -d $HADOOP_HOME hdfs
echo "hdfs:hdfs" | sudo chpasswd hdfs

# download Hadoop if not present
if [ ! -f $RESDIR/$HADOOP_FILE ];
then
	echo "Downloading Hadoop"
	sudo wget -O $RESDIR/$HADOOP_FILE $HADOOP_URL
fi
tar -xzf $RESDIR/$HADOOP_FILE
sudo cp -r hadoop-$HADOOP_VERSION/* $HADOOP_HOME
sudo rm -r hadoop-$HADOOP_VERSION

#add environment variables for hadoop
ENV="
HADOOP_HOME=$HADOOP_HOME
HADOOP_COMMON_HOME=$HADOOP_HOME
HADOOP_HDFS_HOME=$HADOOP_HOME
HADOOP_MAPRED_HOME=$HADOOP_HOME
HADOOP_YARN_HOME=$HADOOP_HOME
HADOOP_OPTS=-Djava.library.path=$HADOOP_HOME/lib/native
HADOOP_COMMON_LIB_NATIVE_DIR=$HADOOP_HOME/lib/native
PATH=$PATH:$HADOOP_HOME/sbin:$HADOOP_HOME/bin
"

echo "$ENV" | sudo tee -a /etc/environment > /dev/null
source /etc/environment

# copy and modify hadoop configuration files
sudo sed -i 'export JAVA_HOME.*' $HADOOP_HOME/etc/hadoop/hadoop-env.sh
echo "export JAVA_HOME=$JAVA_HOME" | sudo tee -a $HADOOP_HOME/etc/hadoop/hadoop-env.sh > /dev/null
sudo cp /vagrant/hadoop/*.xml $HADOOP_HOME/etc/hadoop/
sudo sed -i 'localhost' $HADOOP_HOME/etc/hadoop/hadoop-env.sh
echo "master.hadoop.lan" | sudo tee -a $HADOOP_HOME/etc/hadoop/slaves > /dev/null

# passwordless login for hdfs user
sudo  mkdir $HADOOP_HOME/.ssh
sudo chmod 700 $HADOOP_HOME.ssh
sudo  ssh-keygen -t dsa -P '' -f $HADOOP_HOME/.ssh/id_dsa
sudo  bash -c "cat $HADOOP_HOME/.ssh/id_dsa.pub >> $HADOOP_HOME/.ssh/authorized_keys"
sudo  bash -c "ssh-keyscan -H localhost >> $HADOOP_HOME/.ssh/known_hosts"
sudo chmod 600 $HADOOP_HOME/.ssh/authorized_keys

# create hdfs storage locations
sudo mkdir -p /opt/volume/namenode
sudo mkdir -p /opt/volume/datanode
sudo chown -R hdfs:hdfs /opt/volume
sudo chown -R hdfs:hdfs /opt/hadoop 

# format name node (once only)
sudo -u hdfs $HADOOP_HOME/bin/hdfs namenode -format

# startup hadoop
sudo -u hdfs $HADOOP_HOME/sbin/start-dfs.sh
sudo -u hdfs $HADOOP_HOME/sbin/start-yarn.sh


echo "Base Hadoop setup complete."




