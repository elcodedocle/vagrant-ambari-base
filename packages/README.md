This folder keeps the packages and tarballs to be installed.

JDK-7u67 and UnlimitedJCEPolicyJDK7.zip
```
wget --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/7u67-b01/jdk-7u67-linux-x64.tar.gz"
```
The name of the Java JDK tarball is hardcoded in the Ambari setup script to jdk-7u67-linux-x64.tar.gz
```
wget --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jce/7/UnlimitedJCEPolicyJDK7.zip"
```

### HDP 2.3 Stack Packages
 
 Your packages folder should contain those tarballs:
 * jdk-7u67-linux-x64.tar.gz
 * UnlimitedJCEPolicyJDK7.zip
 * PADS-1.3.1.0-15874-rhel5_x86_64.tar
 * hawq-plugin-hdp-1.3.0-190.tar

