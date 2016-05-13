#!/bin/bash 

for i in $(eval echo {1..$1}); do 
  su - -c "ssh -o StrictHostKeyChecking=no $2@sg$i.imatiasl.lan 'sudo ls;'" $2
  su - -c "scp /etc/yum.repos.d/ambari.repo $2@sg$i.imatiasl.lan:" $2
  su - -c "ssh -o StrictHostKeyChecking=no $2@sg$i.imatiasl.lan 'sudo cp ~/ambari.repo /etc/yum.repos.d/;'" $2

  su - -c "ssh -o StrictHostKeyChecking=no $2@sg$i.imatiasl.lan 'sudo yum -y install ambari-agent;'" $2
  su - -c "ssh -o StrictHostKeyChecking=no $2@sg$i.imatiasl.lan 'sudo sed -i 16s/.*/hostname=ambari.imatiasl.lan/ /etc/ambari-agent/conf/ambari-agent.ini;' " $2
  su - -c "ssh -o StrictHostKeyChecking=no $2@sg$i.imatiasl.lan 'sudo ambari-agent start ;'" $2
done
