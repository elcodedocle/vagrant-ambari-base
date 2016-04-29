#!/bin/bash

cp /vagrant/id_rsa.pub /home/vagrant/.ssh/
cp /vagrant/id_rsa /home/vagrant/.ssh/
chown vagrant:vagrant /home/vagrant/.ssh/id_rsa*
chmod 400 /home/vagrant/.ssh/ir_dsa
cat /vagrant/id_rsa.pub | cat >> ~/.ssh/authorized_keys
 
rpm -ivh http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm      
 
yum -y install httpd wget python-pip git
service httpd start

pip install requests

mkdir /staging
chmod -R a+rx /staging 

tar -xvzf /vagrant/packages/PADS-1.3.1.0-15874-rhel5_x86_64.tar -C /staging/
tar -xvzf /vagrant/packages/hawq-plugin-hdp-1.3.0-190.tar -C /staging/

for f in /staging/**/setup_repo.sh
do
 $f
done

wget -nv http://public-repo-1.hortonworks.com/ambari/centos6/2.x/updates/2.1.0/ambari.repo -O /etc/yum.repos.d/ambari.repo
wget -nv http://public-repo-1.hortonworks.com/HDP/centos6/2.x/updates/2.3.0.0/hdp.repo -O /etc/yum.repos.d/hdp.repo

wget -nv http://repo.spring.io/yum-release/spring-xd/1.3/spring-xd-1.3.repo -O /etc/yum.repos.d/spring-xd-1.3.repo

wget -nv https://bintray.com/big-data/rpm/rpm -O /etc/yum.repos.d/bintray-big-data-rpm.repo

yum -y install elasticsearch-yarn-ambari-plugin-hdp23

yum -y install geode-ambari-plugin-hdp23

yum -y install ambari-server

cp /vagrant/packages/jdk-8u40-linux-x64.tar.gz /var/lib/ambari-server/resources/
cp /vagrant/packages/jce_policy-8.zip /var/lib/ambari-server/resources/


yum -y install /staging/hawq-plugin-hdp-1.3.0/hawq-plugin-1.3.0-190.noarch.rpm

yum -y install spring-xd-plugin-hdp23-alpha

ambari-server setup -s
ambari-server start

#curl --user admin:admin -H 'X-Requested-By:ambari' -X GET http://ambari.localdomain:8080/api/v1/stacks/HDP/versions/2.3
while [ -n "$(curl --user admin:admin -H 'X-Requested-By:ambari' -X GET http://ambari.localdomain:8080/api/v1/stacks/HDP/versions/2.3)" ]; do
  echo "Try again..."
  sleep 2
done

sleep 15

python /vagrant/provision/SetRepos.py HDP 2.3

curl --user admin:admin -H 'X-Requested-By:ambari' -X GET http://ambari.localdomain:8080/api/v1/stacks/HDP/versions/2.3/operating_systems/redhat6/repositories

yum install -y ambari-agent
sudo ambari-agent start
