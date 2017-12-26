#!/bin/bash
#download rpm if not present

KAFKA_VERSION="1.0.0"
KAFKA_NAME="kafka_2.12-$KAFKA_VERSION"
KAFKA_TARGET="/vagrant/tars/"

echo Downloading kafka...$KAFKA_VERSION 

if [ ! -f  $KAFKA_TARGET/$KAFKA_NAME.tgz ]; then
   mkdir -p $KAFKA_TARGET
   wget -O "$KAFKA_TARGET/$KAFKA_NAME.tgz" http://apache.claz.org/kafka/"$KAFKA_VERSION/$KAFKA_NAME.tgz"
fi

#disabling iptables
service iptables stop

echo "installing dos2unix"
yum install -y dos2unix

echo "installing jdk"
yum install -y java

echo "installing kafka"
if [ ! -d $KAFKA_NAME ]; then 
   tar -zxvf $KAFKA_TARGET/$KAFKA_NAME.tgz
fi

echo "create kafka symlink"
ln -sf "$KAFKA_NAME" kafka

chown vagrant:vagrant -R $KAFKA_NAME

echo "done installing jdk and Kafka"

# chmod scripts
chmod u+x /vagrant/scripts/*.sh
dos2unix /vagrant/scripts/*.sh
