This folder keeps the packages and tarballs to be installed.

JDK-8u91 and jce_policy-8.zip
```
wget --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/8u91-b14/jdk-8u91-linux-x64.tar.gz"
```
The name of the Java JDK tarball is hardcoded in the Ambari setup script to jdk-8u91-linux-x64.tar.gz
```
wget --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jce/8/jce_policy-8.zip"
```

### HDP 2.4 Stack Packages
 
 Your packages folder should contain those tarballs:
 * jdk-8u91-linux-x64.tar.gz
 * jce_policy-8.zip

