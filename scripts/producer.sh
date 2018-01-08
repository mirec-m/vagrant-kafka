#!/bin/bash

if [ $# -gt 0 ]; then
    $HOME/kafka/bin/kafka-console-producer.sh --topic "$1" --broker-list broker-1:9092,broker-2:9092,broker-3:9092
else
    echo "Usage: "$(basename $0)" <topic_name>"
fi
