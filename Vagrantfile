# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  config.vm.box = "centos/7"
  config.vm.provider "hyperv"

  config.ssh.forward_agent = true # So that boxes don't have to setup key-less ssh
  config.ssh.insert_key = false # To generate a new ssh key and don't use the default Vagrant one

  config.hostmanager.enabled = true
  config.hostmanager.manage_guest = true
  config.hostmanager.include_offline = false

  config.vm.synced_folder ".", "/vagrant", type: "rsync"

  # common provisioning for all 
  config.vm.provision "shell", path: "scripts/init.sh"

  # configure zookeeper cluster
  (1..3).each do |i|
    config.vm.define "zookeeper-#{i}" do |s|
    
      config.vm.provider "hyperv" do |h|
        h.enable_virtualization_extensions = true
        # h.differencing_disk = true
        h.vmname = "zookeeper-#{i}"
        h.memory = 512
        h.maxmemory = 2048
        h.cpus = 2
      end

      s.vm.network "private_network", type: "dhcp"
      s.vm.provision "shell", path: "scripts/set-hostname.sh", args:"zookeeper-#{i}"
      s.vm.provision "shell", path: "scripts/zookeeper.sh", args:"#{i}", privileged: false, run: "always"
    end
  end

  # configure brokers
  (1..3).each do |i|
    config.vm.define "broker-#{i}" do |s|
      
      config.vm.provider "hyperv" do |h|
        h.enable_virtualization_extensions = true
        # h.differencing_disk = true
        h.vmname = "broker-#{i}"
        h.memory = 512
        h.maxmemory = 2048
        h.cpus = 2
      end

      s.vm.network "private_network", type: "dhcp"
      s.vm.provision "shell", path: "scripts/set-hostname.sh", args:"broker-#{i}"
      s.vm.provision "shell", path: "scripts/broker.sh", args:"#{i}", privileged: false, run: "always"
    end
  end

end