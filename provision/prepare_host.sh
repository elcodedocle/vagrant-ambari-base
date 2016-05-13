#!/bin/bash
 
AMBARI_HOSTNAME=$1
AMBARI_HOSTNAME_FQDN=$2
NUMBER_OF_CLUSTER_NODES=$3

EATME=1

while [$EATME -gt 0]; do

yum clean all
rm -Rf /var/cache/yum/x86_64/6/
yum -y update
yum -y install mysql-connector-java
 
yum -y install nc expect ed ntp dmidecode pciutils

/etc/init.d/ntpd stop;
mv /etc/localtime /etc/localtime.bak; 
ln -s /usr/share/zoneinfo/Europe/Madrid /etc/localtime; 
/etc/init.d/ntpd start

# Create and set the hosts file like:
#
# 10.7.0.91 ambari.imatiasl.lan  ambari
# 10.7.0.92 sg1.imatiasl.lan  sg1
# ...
# 10.7.0.91+N sgN.imatiasl.lan  sgN

cat > /etc/hosts <<EOF 
127.0.0.1     localhost.localdomain    localhost
::1           localhost6.localdomain6  localhost6
 
EOF

echo "10.7.0.91 $AMBARI_HOSTNAME_FQDN  $AMBARI_HOSTNAME" >> /etc/hosts
   
for i in $(eval echo {1..$NUMBER_OF_CLUSTER_NODES}); do 
   echo "10.7.0.$((91 + $i)) sg$i.imatiasl.lan sg$i" >> /etc/hosts 
done

cp /vagrant/id_rsa.pub /home/vagrant/.ssh/
cat /home/vagrant/.ssh/id_rsa.pub >> /home/vagrant/.ssh/authorized_keys

systemctl disable firewalld
systemctl stop firewalld
echo "umask 022" >> /etc/profile
echo "echo 'never' > /sys/kernel/mm/redhat_transparent_hugepage/defrag" >> /etc/rc.local
echo "echo 'never' > /sys/kernel/mm/redhat_transparent_hugepage/enabled" >> /etc/rc.local
source /etc/rc.local
EATME=0
done
