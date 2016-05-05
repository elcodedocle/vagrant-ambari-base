## Ambari Blueprints

[Ambari Blueprints](http://docs.hortonworks.com/HDPDocuments/Ambari-2.2.1.1/bk_ambari_reference_guide/content/ch_using_ambari_blueprints.html) provide an API to perform cluster installations. You can build a reusable “blueprint” that defines which Stack to use, how Service Components should be laid-out across a cluster, and what configurations to set.

You can create your own blueprint file and select it through the [Vagrantfile](../Vagrantfile) `BLUEPRINT_FILE_NAME` property. 

###### Host Mapping
> Tells Ambari which blueprint it shoud use and which host should be in which host group. With the attribute `blueprint` you can define the name of the blueprint. Then you can define the hosts of each host group. e.g. we define the host `sg1.localdomain` to be in `host_group_1` of `blueprint-c1` 

You can build your own host-mapping file and select it through the [Vagrantfile](../Vagrantfile) `HOST_MAPPING_FILE_NAME` property. 

###### Stacks
Currently the following stacks are supported: 
* HDP2.4 - Hortonworks 2.4, Ambari 2.2.1
_Note: All custom `blueprints` and `host-mapping` files must be stored in the `/blueprints` subfolder!_

#### Host Mapping Name Convention
To simplify the Vagrantfile the following hostname convention is enforced:

* Ambari hostname - defaults to `ambari.localdomain`. You can override the `ambari` prefix via the [Vagrantfile](../Vagrantfile) `AMBARI_HOSTNAME_PREFIX`property. The domain is fixed to `.localdomain`. 
* Cluster hostnames - cluster nodes are named like this: `sg<NodeIndex>.localdomain`. For a cluster with N nodes, the hostnames are: `sg1.localdomain` ... `sgN.localdomain`. Index starts from `1` and increments consecutively (**no gaps**) to N. `N` is the size of the cluster excluding the Ambari node.

Follow this convention in your **Host Mapping** specs or Vagrantfile will not be able to provision the required VMs. If you alter the Ambari name make sure it does not overlap with any of the cluster node names. 

## Predefined Blueprints and Host-Mappings

#### Hortonworks HDP2.4, Ambari-2.2 Blueprints

The [springxd-cluster-blueprint.json](springxd-cluster-blueprint.json) and [springxd-cluster-hostmapping.json](springxd-cluster-hostmapping.json) spec defines a 2 node proof-of-concept cluster.

Host name        | Components
---------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
sg1.imatiasl.lan | Storm DRPC Server, ElasticSearch YARN , HBase Master, Kafka Broker, NameNode, Nimbus, Spark History Server, Spring XD Admin, Spring XD HSQL Database, Storm UI Server , ZooKeeper Server, DataNode, Flume, RegionServer, Ambari Metrics Monitor, NodeManager, Storm Supervisor
sg2.imatiasl.lan | App Timeline Server, History Server, Hive Metastore, HiveServer2, Hive MySQL Server, ResourceManager, SNameNode, WebHCat Server, ZooKeeper Server, DataNode, Flume, HBase RegionServer, Ambari Metrics Monitor, Ambari Metrics Collector, NodeManager, Storm Supervisor

#### References 
* [Ambari Blueprints API](https://cwiki.apache.org/confluence/display/AMBARI/Blueprints)
