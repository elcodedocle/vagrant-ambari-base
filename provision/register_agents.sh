#!/bin/bash 

for i in $(eval echo {1..$1}); do 
  su - -c "ssh -o StrictHostKeyChecking=no vagrant@sg$i.imatiasl.lan 'sudo ls;'" vagrant
  su - -c "scp /etc/yum.repos.d/ambari.repo vagrant@sg$i.imatiasl.lan:" vagrant
  su - -c "ssh -o StrictHostKeyChecking=no vagrant@sg$i.imatiasl.lan 'sudo cp ~/ambari.repo /etc/yum.repos.d/;'" vagrant

  su - -c "ssh -o StrictHostKeyChecking=no vagrant@sg$i.imatiasl.lan 'sudo yum -y install ambari-agent;'" vagrant
  su - -c "ssh -o StrictHostKeyChecking=no vagrant@sg$i.imatiasl.lan 'sudo sed -i 16s/.*/hostname=ambari.imatiasl.lan/ /etc/ambari-agent/conf/ambari-agent.ini;' " vagrant
  su - -c "ssh -o StrictHostKeyChecking=no vagrant@sg$i.imatiasl.lan 'sudo ambari-agent start ;'" vagrant
done
