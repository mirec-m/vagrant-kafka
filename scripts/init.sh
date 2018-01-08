#!/bin/bash

# exit on error
set -e
# report error
set -o errexit

echo "Installing dependencies"
# yum clean all
yum install -y wget dos2unix java-1.8.0-openjdk

# Download and install kafka if not present
KAFKA_VERSION="1.0.0"
KAFKA_NAME="kafka_2.12-$KAFKA_VERSION"
KAFKA_TARGET="/vagrant/tars/"

if [ ! -f  $KAFKA_TARGET/$KAFKA_NAME.tgz ]; then
   echo "Downloading kafka - http://apache.claz.org/kafka/$KAFKA_VERSION/$KAFKA_NAME.tgz"
   mkdir -p $KAFKA_TARGET
   wget -O "$KAFKA_TARGET/$KAFKA_NAME.tgz" http://apache.claz.org/kafka/"$KAFKA_VERSION/$KAFKA_NAME.tgz"
fi

echo "Installing kafka"
if [ ! -d $KAFKA_NAME ]; then 
   tar -zxvf $KAFKA_TARGET/$KAFKA_NAME.tgz
fi

echo "create kafka symlink"
ln -sf "$KAFKA_NAME" kafka

chown vagrant:vagrant -R $KAFKA_NAME

# chmod scripts
chmod u+x /vagrant/scripts/*.sh
dos2unix /vagrant/scripts/*.sh
