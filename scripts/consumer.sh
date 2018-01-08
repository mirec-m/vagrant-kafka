#!/bin/bash

# exit on error
set -e

if [ $# -gt 0 ]; then
    $HOME/kafka/bin/kafka-console-consumer.sh --from-beginning --topic $1 --zookeeper zookeeper-1:2181,zookeeper-2:2181,zookeeper-3:2181
else
    echo "Usage: "$(basename $0)" <topic_name>"
fi

