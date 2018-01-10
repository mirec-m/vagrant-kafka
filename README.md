Vagrant - Kafka
=============

Vagrant configuration to setup a partitioned Apache Kafka installation with clustered Apache Zookeeper on Hyper-v.

This configuration will start and provision six CentOS 7 VMs:

* Three hosts forming a three node Apache Zookeeper Quorum (Replicated ZooKeeper)
* Three Apache Kafka nodes with one broker each

Each host is a latest CentOS 7 (currently 7.4) 64-bit VM provisioned with JDK 8 and Kafka 1.0.

Here we will be using the version of Zookeeper that comes pre-packaged with Kafka.

Notes:
* This set-up is using "Default switch" with dynamic IPs
* Vagrant hostmanager plugin manages the /etc/hosts file in order to keep up with the IP changes
* Network speed/accessibility can be affected in cases where the "Default switch" network has different profile than the underlying network (https://winaero.com/blog/network-location-type-powershell-windows-10/)

Pre-requisites
-------------------------

* Vagrant (tested on 2.0.1)
* cwRsync (tested on 5.5.0)
* Hyperv

Setup
-------------------------

1) Install vagrant hostmanager plugin

```vagrant plugin install vagrant-hostmanager```

This allows us to use dynamic IPs without running DNS server.
Dynamic IPs come as a courtesy of "Default Switch" used in this case.

2) Clone this repo and execute ```vagrant up```. This will take a while the first time as it downloads all required dependencies for you.

Kafka is accessible (symlinked) on all hosts at ```$HOME/kafka/```

Zookeeper servers bind to port 2181. Kafka brokers bind to port 9092. 

Let's test it!
-------------------------

First test that all nodes are up ```vagrant status```. The result should be similar to this:

```
Current machine states:

zookeeper-1                running (hyperv)
zookeeper-2                running (hyperv)
zookeeper-3                running (hyperv)
broker-1                   running (hyperv)
broker-2                   running (hyperv)
broker-3                   running (hyperv)


This environment represents multiple VMs. The VMs are all listed
above with their current state. For more information about a specific
VM, run 'vagrant status NAME''.
```

Login to any host with e.g., ```vagrant ssh broker-1```. Some scripts have been included for convenience:

* Create a new topic ```/vagrant/scripts/create_topic.sh <topic name>``` (create as many as you see fit)

* Topics can be listed with ```/vagrant/scripts/list-topics.sh```

* Start a console producer ```/vagrant/scripts/producer.sh <opic name>```. Type few messages and seperate them with new lines (`ctl-C` to exit). 

* ```/vagrant/scripts/consumer.sh <topic name>```: this will create a console consumer, getting messages from the topic created before. It will read all the messages each time starting from the beginning.

Now anything you type in producer, it will show on the consumer. 


#### Teardown


To destroy all the VMs

```bash
vagrant destroy -f
```


##Insights

### Zookeeper (ZK)

Kafka is using ZK for its coordination, bookkeeping, and configuration. 
Here are some commands you can run on any of the nodes to see some of the internal ZK structures created by Kafka. 

#### Open a ZK shell

```$HOME/kafka/bin/zookeeper-shell.sh zookeeper-1:2181``` 

(you can use the IP/name of any of the ZK servers)


Inside the shell we can browse the zNodes similar to a Linux filesystem: 

```bash
ls /
[controller, controller_epoch, brokers, zookeeper, admin, isr_change_notification, consumers, config]

ls /brokers/topics
[t1, t2]

ls /brokers/ids
[1, 2, 3]
```

We can see that there are two topics created (t1, t2) and we already know that we have three brokers with ids 1,2,3. 

After you have enough fun browsing ZK, type `ctl-C` to exit the shell.

#### Get ZK version

First we need to instal `nc`: 

```bash
sudo yum install nc -y
```

To get the version of ZK type:

```bash
echo status | nc zookeeper-1 2181
```

You can replace zookeeper-1 with any ZK zookeeper-<1,2,3> and execute the above command from any node within the cluster. 

*Q: Which Zookeeper server is the leader?*

Here is a simple script that asks each server for its mode:

```bash
for i in 1 2 3; do
   echo "zookeeper-$i is a "$(echo status | nc zookeeper-$i 2181 | grep ^Mode | awk '{print $2}')
done
```

### Kafka

Let's explore other ways to ingest data to Kafa from the command line. 

Login to any of the 6 nodes

```bash
vagrant ssh zookeeper1
```

Create a topic 

```bash
 /vagrant/scripts/create_topic.sh test-one
```

Send data to the Kafka topic

```bash
echo "Yet another line from stdin" | ./kafka/bin/kafka-console-producer.sh \
   --topic test-one --broker-list broker-1:9092,broker-2:9092,broker-3:9092
```

You can then test that the line was added by running the consumer

```bash
/vagrant/scripts/consumer.sh test-one
```

##### Add a continues stream of data

Running `vmstat` will periodically export stats about the VM you are attached to. 

```bash
>vmstat -a 1 -n 100

procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu-----
 r  b   swpd   free  inact active   si   so    bi    bo   in   cs us sy id wa st
 0  0    960 113312 207368 130500    0    0    82   197  130  176  0  1 99  0  0
 0  0    960 113312 207368 130500    0    0     0     0   60   76  0  0 100  0  0
 0  0    960 113304 207368 130540    0    0     0     0   58   81  0  0 100  0  0
 0  0    960 113304 207368 130540    0    0     0     0   53   76  0  1 99  0  0
 0  0    960 113304 207368 130540    0    0     0     0   53   78  0  0 100  0  0
 0  0    960 113304 207368 130540    0    0     0    16   64   90  0  0 100  0  0
```

Redirecing this output to Kafka creates a basic form of a streaming producer.

```bash
vmstat -a 1 -n 100 | ./kafka_2.10-0.9.0.1/bin/kafka-console-producer.sh \
   --topic test-one --broker-list broker-1:9092,broker-2:9092,broker-3:9092 &
```

While the producer runs in the background you can start the consumer to see what happens

```bash
/vagrant/scripts/consumer.sh test-one
```

You should be seeing the output of `vmstat` in the consumer console. 

When you are all done, kill the consumer by `ctl-C`. The producer will terminate by itself after 100 seconds.


#### Offsets

The `create_topic.sh` script creates a topic with replication factor 3 and 1 number of partitions. 

Assuming you have completed the `vmstat` example above using topic `test-one`:

```bash
/vagrant/scripts/get-offset-info.sh test-one
test-one:0:102
```

There is one partition (id 0) and the last offset was 102 (from `vmstat`: 100 lines of reports + 2 header lines)
We asked Kafka for the last offset written so far using `--time -1` (as seen in [get-offset-info.sh](scripts/get-offset-info.sh)). You can change the time to `-2` to get the first offset. 

