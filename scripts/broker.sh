#!/bin/bash

#bootstrap server
if [ $# -gt 0 ]; then
   $HOME/kafka/bin/kafka-server-start.sh -daemon /vagrant/config/server$1.properties
else
    echo "Usage: "$(basename $0)" <topic_name>"
fi
