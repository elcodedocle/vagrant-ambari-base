#!/bin/bash
 
AMBARI_HOSTNAME=$1
AMBARI_HOSTNAME_FQDN=$2
NUMBER_OF_CLUSTER_NODES=$3
VAGRANT_USER=$4

EATME=1

while [ $EATME -gt 0 ]; do

    yum clean all
    rm -Rf /var/cache/yum/x86_64/6/
    yum -y update
    yum -y install mysql-connector-java

    yum -y install nc expect ed ntp dmidecode pciutils

    systemctl stop ntpd;
    mv /etc/localtime /etc/localtime.bak; 
    ln -s /usr/share/zoneinfo/Europe/Madrid /etc/localtime; 
    systemctl start ntpd;

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

    cp /vagrant/id_rsa.pub /home/$VAGRANT_USER/.ssh/
    cat /home/$1/.ssh/id_rsa.pub >> /home/$VAGRANT_USER/.ssh/authorized_keys

    echo "umask 022" >> /etc/profile
    echo "echo 'never' > /sys/kernel/mm/transparent_hugepage/defrag" >> /etc/rc.local
    echo "echo 'never' > /sys/kernel/mm/transparent_hugepage/enabled" >> /etc/rc.local
    source /etc/rc.local

    EATME=0

done
