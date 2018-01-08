#!/bin/bash

$HOME/kafka/bin/kafka-topics.sh --list --zookeeper zookeeper-1:2181,zookeeper-2:2181,zookeeper-3:2182
