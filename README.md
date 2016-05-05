vagrant-ambari-base project
=============================
#####*Base project providing provisioning and orchestration for HDFS/Hadoop-based clustered cloud platforms.*

 Copyright (C) 2016 Imatia Innovation S.L.<br/>
 All rights reserved.<br />

### Requirements
 
 - git
 - vagrant
 - tarballs listed in packages/README.md
 
Depending on configuration settings, per node*:
 - 8-24 GB of RAM 
 - 1-8 dedicated x64 cores @ >2Ghz
 - A few hundred GB of HDD
 - 1-10Gb Ethernet LAN connection (preferrably dual)
 
### How to use
 - Clone the repo:
```bash
git clone https://bitbucket.org/imatia/vagrant-ambari-base
```
 - Generate a keypair on the project root folder:
```bash
cd vagrant-ambari-base
openssl genpkey -algorithm RSA -out id_rsa -pkeyopt rsa_keygen_bits:2048
openssl rsa -pubout -in id_rsa -out id_rsa.pub
```
 - Check out configuration parameters in the provided Vagrantfile
 - Bring up the cluster
```bash
vagrant up
```
 - Navigate to the dashboard on http://ambari.imatiasl.lan:8080/main/dashboard

### Acks

Check out the provided [NOTICE](NOTICE) file.


Enjoy!


*More info on provisioning: https://www.safaribooksonline.com/library/view/hadoop-operations/9781449327279/ch04.html
