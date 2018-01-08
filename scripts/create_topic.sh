#!/bin/bash

if [ $# -gt 0 ]; then
    $HOME/kafka/bin/kafka-topics.sh --replication-factor 2 --partitions 1 --topic $1 --create --zookeeper zookeeper-1:2181,zookeeper-2:2181,zookeeper-3:2182
else
    echo "Usage: "$(basename $0)" <topic_name>"
fi
