#!/bin/bash

cp /vagrant/id_rsa.pub /home/vagrant/.ssh/
cp /vagrant/id_rsa /home/vagrant/.ssh/
chown vagrant:vagrant /home/vagrant/.ssh/id_rsa*
chmod 400 /home/vagrant/.ssh/id_rsa
cat /vagrant/id_rsa.pub | cat >> /home/vagrant/.ssh/authorized_keys
 
rpm -ivh http://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
 
yum -y install httpd wget python-pip git
service httpd start

pip install requests

mkdir /staging
chmod -R a+rx /staging 

for f in /staging/**/setup_repo.sh
do
 $f
done

wget -nv http://public-repo-1.hortonworks.com/ambari/centos7/2.x/updates/2.2.1.1/ambari.repo -O /etc/yum.repos.d/ambari.repo
wget -nv http://public-repo-1.hortonworks.com/HDP/centos7/2.x/updates/2.4.0.0/hdp.repo -O /etc/yum.repos.d/hdp.repo

wget -nv http://repo.spring.io/yum-release/spring-xd/1.3/spring-xd-1.3.repo -O /etc/yum.repos.d/spring-xd-1.3.repo

yum -y install ambari-server

cp /vagrant/packages/jdk-8u91-linux-x64.tar.gz /var/lib/ambari-server/resources/
cp /vagrant/packages/jce_policy-8.zip /var/lib/ambari-server/resources/

yum -y install spring-xd-plugin-hdp

ambari-server setup -s
ambari-server start

#curl --user admin:admin -H 'X-Requested-By:ambari' -X GET http://ambari.imatiasl.lan:8080/api/v1/stacks/HDP/versions/2.4
while [ -n "$(curl --user admin:admin -H 'X-Requested-By:ambari' -X GET http://ambari.imatiasl.lan:8080/api/v1/stacks/HDP/versions/2.4)" ]; do
  echo "Try again..."
  sleep 2
done

sleep 15

python /vagrant/provision/SetRepos.py HDP 2.4

curl --user admin:admin -H 'X-Requested-By:ambari' -X GET http://ambari.imatiasl.lan:8080/api/v1/stacks/HDP/versions/2.4/operating_systems/redhat7/repositories

