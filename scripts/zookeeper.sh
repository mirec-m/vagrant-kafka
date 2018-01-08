#!/bin/bash

# create myid file. see http://zookeeper.apache.org/doc/r3.1.1/zookeeperAdmin.html#sc_zkMulitServerSetup
if [ ! -d /tmp/zookeeper ]; then
    echo "Creating zookeeper data dir..."
    mkdir /tmp/zookeeper
    echo $1 > /tmp/zookeeper/myid
fi

echo "Stopping previous instance of zookeeper server"
$HOME/kafka/bin/zookeeper-server-stop.sh

echo "Starting zookeeper"
nohup $HOME/kafka/bin/zookeeper-server-start.sh /vagrant/config/zookeeper.properties > /tmp/zookeeper.log 2>&1 &
sleep 4
