# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

require 'set'
require 'rubygems'
require 'json'

###############################################################################
#    CONFIG PARAMETERS
###############################################################################

# This only affects su and ssh commands on shell provision scripts.
# Tipycally, use "centos" for aws provider, "vagrant" for virtualbox or vmware providers
VAGRANT_USER = "centos"

# Note for AWS launch (provider set to aws) vagrant aws plugin 
# ( https://github.com/mitchellh/vagrant-aws ) 
# must be installed and the following environment variables must be set:
#   AWS_ACCESS_KEY - AWS API access key
#   AWS_SECRET_KEY - AWS API secret key
#   AWS_KEYNAME - Name of the AWS EC2 SSH key to use
#   AWS_KEYPATH - Route to .pem keyfile matching the selected SSH key
# Configuration of AWS EC2 deployment:
AWS_REGION = "us-east-1"
# Centos 7 with updates on us-east-1 (N. Virginia) AMI id 
# ( See https://aws.amazon.com/marketplace/pp/B00O7WM7QW )
AWS_AMI = "ami-6d1c2007"
# Must be EBS-based. 8GB RAM, 2 vCores minimum recommended
AWS_AMBARI_INSTANCE_TYPE = "m4.large"
# Must be EBS-based. 8GB RAM, 2 vCores minimum recommended
AWS_INSTANCE_TYPE = "m4.large"
AWS_SSH_USERNAME = VAGRANT_USER
# The AWS VPC subnet where the cluster will be deployed. 
# It should be configured with CIDR mask 10.7.0.0/24
# Ambari host will have also a randomly assigned public ip
# (If you want to associate your own elastic ip check elastic_ip parameter)
AWS_VPC_SUBNET_ID = "subnet-c8620c90"
AWS_VPC_SECURITY_GROUP_ID = "sg-1301c268"
AWS_AMBARI_EBS_DISK_SIZE_GB = 100
AWS_NODE_EBS_DISK_SIZE_GB = 200

# must be located on /blueprints subfolder
BLUEPRINT_FILE_NAME = "springxd-cluster-blueprint.json"

# must be located on /blueprints subfolder
HOST_MAPPING_FILE_NAME = "springxd-cluster-hostmapping.json"

# Set the name of the cluster to be deployed
CLUSTER_NAME = "CLUSTER_SG"

# Suitable Vagrant boxes:
# - bigdata/centos6.4_x86_64 - 40G disk space.
# - bigdata/centos6.4_x86_64_small - just 8G of disk space. 
# - bento/centos-6.7 - CentOS6.7 Vagrant box
# - bento/centos-7.2 - CentOS7.2 Vagrant box
# For AWS:
# - andytson/aws-dummy
# For Proxmox:
# - See https://github.com/telcat/vagrant-proxmox/tree/master/dummy_box
VM_BOX = "andytson/aws-dummy"
VM_BOOT_TIMEOUT = 900

#Memory allocated for the AMBARI VM
AMBARI_NODE_VM_MEMORY_MB = "6144"

# Memory allocated per HDP node
HDP_NODE_VM_MEMORY_MB = "5120"

# Ambari host name prefix. Suffix fixed to '.imatiasl.lan'.
AMBARI_HOSTNAME_PREFIX = "ambari"

# TRUE to deploy a cluster defined with BLUEPRINT_FILE_NAME and HOST_MAPPING_FILE_NAME.
# FALSE to stop the installation after the Ambari Server installation. 
DEPLOY_BLUEPRINT_CLUSTER = TRUE

# Proxmox provider settings:
# The following environment variables must be set:
# PROXMOX_USER_NAME
# PROXMOX_PASSWORD
# PROXMOX_ENDPOINT
PROXMOX_AMBARI_QEMU_TEMPLATE = 'local:vztmpl/centos-7-default.tar.gz'
PROXMOX_NODE_QEMU_TEMPLATE = 'local:vztmpl/centos-7-default.tar.gz'
PROXMOX_AMBARI_DISK_SIZE = "100GB"
PROXMOX_NODE_DISK_SIZE = "200GB"
PROXMOX_ID_RANGE_START = 300

###############################################################################
#    END CONFIG PARAMETERS
###############################################################################
# Maps provisioning script to the supported stack
INSTALL_AMBARI_STACK = {
  "HDP2.4" => "provision/install_ambari.sh"
}

AMBARI_HOSTNAME_FQDN = "#{AMBARI_HOSTNAME_PREFIX}.imatiasl.lan"

# Parse the blueprint spec
blueprint_spec = JSON.parse(open("blueprints/" + BLUEPRINT_FILE_NAME).read)
BLUEPRINT_NAME = blueprint_spec["Blueprints"]["blueprint_name"]
STACK_NAME = blueprint_spec['Blueprints']['stack_name']
STACK_VERSION = blueprint_spec['Blueprints']['stack_version']
AMBARI_PROVISION_SCRIPT = INSTALL_AMBARI_STACK[STACK_NAME + STACK_VERSION]

# Print deployment info
print "CLUSTER NAME: #{CLUSTER_NAME} \nBLUEPRINT NAME: #{BLUEPRINT_NAME} \n"
print "STACK: #{blueprint_spec['Blueprints']['stack_name']}-#{blueprint_spec['Blueprints']['stack_version']} \n"
print "BLUEPRINT FILE: #{BLUEPRINT_FILE_NAME} \nHOST-MAPPING FILE: #{HOST_MAPPING_FILE_NAME} \n"
print "Ambari Provision Script: #{AMBARI_PROVISION_SCRIPT}\n"

# Read the host-mapping file to extract the blueprint name and the cluster node hostnames
host_mapping = JSON.parse(open("blueprints/" + HOST_MAPPING_FILE_NAME).read)

# Extract the Blueprint name from the host mapping file
HOST_MAPPING_BLUEPRINT_NAME = host_mapping["blueprint"]

# Validate that the Blueprint set in the host mapping file aligns with the name of the blueprint provided
if (BLUEPRINT_NAME != HOST_MAPPING_BLUEPRINT_NAME)
  print "Host-Mapping blueprint name:(#{HOST_MAPPING_BLUEPRINT_NAME}) doesn't match the Blueprint: (#{BLUEPRINT_NAME})! \n"
  exit
end

# List of cluster node hostnames. Convention is: 'sg<Number>.imatiasl.lan'
NODES = Set.new([])

# Extract the cluster hostnames from the blueprint host mapping file
host_mapping["host_groups"].each do |group|
  group["hosts"].each do |host| NODES << host["fqdn"].strip end
end

# Ambari host can be use to deploy services but should not be part of the sg[1-n] range
# as it is provisioned differently 
# NODES.delete(AMBARI_HOSTNAME_FQDN);

NUMBER_OF_CLUSTER_NODES = NODES.size

print "Number of cluster nodes (excluding Ambari): #{NUMBER_OF_CLUSTER_NODES} \n"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  
  # Provision VM for every HDP node
  (1..NUMBER_OF_CLUSTER_NODES).each do |i|

    hdp_vm_name = "sg#{i}"
    
    hdp_host_name = "sg#{i}.imatiasl.lan"
    
    config.vm.define hdp_vm_name.to_sym do |hdp_conf|
      
      hdp_conf.vm.box = VM_BOX

      hdp_conf.vm.boot_timeout = VM_BOOT_TIMEOUT
      
      hdp_conf.vm.provider :virtualbox do |v|
        v.gui = false
        v.name = hdp_vm_name
        v.customize ["modifyvm", :id, "--memory", HDP_NODE_VM_MEMORY_MB]
      end
      
      hdp_conf.vm.provider "vmware_fusion" do |v|
        v.name = hdp_vm_name
        v.vmx["memsize"]  = HDP_NODE_VM_MEMORY_MB
      end
      
      hdp_conf.vm.provider :aws do |aws, override|
        aws.access_key_id = ENV['AWS_ACCESS_KEY']
        aws.secret_access_key = ENV['AWS_SECRET_KEY']
        aws.keypair_name = ENV['AWS_KEYNAME']
        aws.ami = AWS_AMI
        aws.instance_type = AWS_AMBARI_INSTANCE_TYPE
        aws.region = AWS_REGION
        aws.security_groups = AWS_VPC_SECURITY_GROUP_ID
        override.ssh.username = AWS_SSH_USERNAME
        override.ssh.private_key_path = ENV['AWS_KEYPATH']
        aws.subnet_id = AWS_VPC_SUBNET_ID
        aws.private_ip_address = "10.7.0.#{i + 91}"
        aws.elastic_ip = true
        aws.block_device_mapping = [{ 'DeviceName' => '/dev/sda1', 'Ebs.VolumeSize' => AWS_NODE_EBS_DISK_SIZE_GB }]
        aws.user_data = File.read("user_data.txt")
      end
      
      config.vm.provider :proxmox do |proxmox|
        proxmox.endpoint = ENV['PROXMOX_ENDPOINT']
        proxmox.user_name = ENV['PROXMOX_USER_NAME']
        proxmox.password = ENV['PROXMOX_PASSWORD']
        proxmox.vm_memory = HDP_NODE_VM_MEMORY_MB
        proxmox.qemu_disk_size = PROXMOX_NODE_DISK_SIZE
        proxmox.vm_name_prefix = CLUSTER_NAME + '_'
        proxmox.vm_id_range = (PROXMOX_ID_RANGE_START + 1)..(PROXMOX_ID_RANGE_START + 1 + NUMBER_OF_CLUSTER_NODES)
        proxmox.vm_type = :qemu
        proxmox.qemu_os = :l26
        proxmox.qemu_storage = 'local'
        proxmox.qemu_template = PROXMOX_AMBARI_QEMU_TEMPLATE
        proxmox.qemu_cores = 2
        proxmox.qemu_sockets = 1
        proxmox.qemu_nic_model = 'virtio'
        proxmox.qemu_bridge = 'vmbr0'
      end

      hdp_conf.vm.host_name = hdp_host_name
      # will be ignored by aws provider (use aws.private_ip_address instead):
      hdp_conf.vm.network :private_network, ip: "10.7.0.#{i + 91}"
  
      #Fix hostname FQDN
      hdp_conf.vm.provision :shell, :inline => "hostname #{hdp_host_name}"

      hdp_conf.vm.provision "shell" do |s|
        s.path = "provision/prepare_host.sh"
        s.args = [AMBARI_HOSTNAME_PREFIX, AMBARI_HOSTNAME_FQDN, NUMBER_OF_CLUSTER_NODES]
      end
    end
  end

  # Provision Ambari VM. Install Ambari Server and deploy a HDP cluster
  AMBARI_VM_NAME = AMBARI_HOSTNAME_PREFIX
  
  config.vm.define AMBARI_VM_NAME do |ambari|
   
   ambari.vm.box = VM_BOX
   ambari.vm.boot_timeout = VM_BOOT_TIMEOUT

   ambari.vm.provider :virtualbox do |v|
     v.gui = false
     v.name = AMBARI_VM_NAME
     v.customize ["modifyvm", :id, "--memory", AMBARI_NODE_VM_MEMORY_MB]
   end

   ambari.vm.provider "aws" do |aws, override|
     aws.access_key_id = ENV['AWS_ACCESS_KEY']
     aws.secret_access_key = ENV['AWS_SECRET_KEY']
     aws.keypair_name = ENV['AWS_KEYNAME']
     aws.ami = AWS_AMI
     aws.instance_type = AWS_INSTANCE_TYPE
     aws.region = AWS_REGION
     aws.security_groups = AWS_VPC_SECURITY_GROUP_ID
     override.ssh.username = AWS_SSH_USERNAME
     override.ssh.private_key_path = ENV['AWS_KEYPATH']
     aws.subnet_id = AWS_VPC_SUBNET_ID
     aws.private_ip_address = "10.7.0.91"
     aws.elastic_ip = true
     aws.block_device_mapping = [{ 'DeviceName' => '/dev/sda1', 'Ebs.VolumeSize' => AWS_AMBARI_EBS_DISK_SIZE_GB }]
     aws.user_data = File.read("user_data.txt")
   end
      
    config.vm.provider :proxmox do |proxmox|
      proxmox.endpoint = ENV['PROXMOX_ENDPOINT']
      proxmox.user_name = ENV['PROXMOX_USER_NAME']
      proxmox.password = ENV['PROXMOX_PASSWORD']
      proxmox.vm_memory = AMBARI_NODE_VM_MEMORY_MB
      proxmox.qemu_disk_size = PROXMOX_AMBARI_DISK_SIZE
      proxmox.vm_name_prefix = CLUSTER_NAME + '_AMBARI_'
      proxmox.vm_id_range = PROXMOX_ID_RANGE_START..PROXMOX_ID_RANGE_START
      proxmox.vm_type = :qemu
      proxmox.qemu_os = :l26
      proxmox.qemu_storage = 'local'
      proxmox.qemu_template = PROXMOX_NODE_QEMU_TEMPLATE
      proxmox.qemu_cores = 2
      proxmox.qemu_sockets = 1
      proxmox.qemu_nic_model = 'virtio'
      proxmox.qemu_bridge = 'vmbr0'
    end

   ambari.vm.provider "vmware_fusion" do |v|
     v.name = AMBARI_VM_NAME
     v.vmx["memsize"]  = AMBARI_NODE_VM_MEMORY_MB
   end

   ambari.vm.hostname = AMBARI_HOSTNAME_FQDN
   # will be ignored by aws provider (use aws.private_ip_address instead):
   ambari.vm.network :private_network, ip: "10.7.0.91" 
#   ambari.vm.network :forwarded_port, guest: 8080, host: 8080

   # Fix hostname FQDN
   ambari.vm.provision :shell, :inline => "hostname " + AMBARI_HOSTNAME_FQDN

   # Initialization common for all nodes
   ambari.vm.provision "shell" do |s|
     s.path = "provision/prepare_host.sh"
     s.args = [AMBARI_HOSTNAME_PREFIX, AMBARI_HOSTNAME_FQDN, NUMBER_OF_CLUSTER_NODES]
   end
   
   # Install Ambari Server
   ambari.vm.provision "shell" do |s|
     s.path = AMBARI_PROVISION_SCRIPT
   end

   # Install Redis (Used as Spring XD transport)
   ambari.vm.provision "shell" do |s|
     s.path = "provision/install_redis.sh"
   end

   # Register the Ambari Agents and all nodes
   ambari.vm.provision "shell" do |s|
     s.path = "provision/register_agents.sh"
     s.args = [NUMBER_OF_CLUSTER_NODES, VAGRANT_USER]
   end

   # Deploy Hadoop Cluster & Services as defined in the Blueprint/Host-Mapping files
   if (DEPLOY_BLUEPRINT_CLUSTER)
     ambari.vm.provision "shell" do |s|
       s.path = "provision/deploy_cluster.sh"
       s.args = [AMBARI_HOSTNAME_FQDN, CLUSTER_NAME, BLUEPRINT_NAME,
                 "/vagrant/blueprints/" + BLUEPRINT_FILE_NAME, 
                 "/vagrant/blueprints/" + HOST_MAPPING_FILE_NAME]
     end
   end
  end
end
