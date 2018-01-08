#!/bin/bash

if [ $# -gt 0 ]; then
   $HOME/kafka/bin/kafka-run-class.sh kafka.tools.GetOffsetShell --broker-list broker-1:9092,broker-2:9092,broker-3:9092 --topic $1 --time -1
else
    echo "Usage: "$(basename $0)" <topic_name>"
fi
