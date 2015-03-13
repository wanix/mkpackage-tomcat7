#!/bin/sh
#Sample pre-install.sh script for easyfpm : https://github.com/wanix/easyfpm.git
#Usage for deb : https://www.debian.org/doc/debian-policy/ch-maintainerscripts.html
#Usage for rpm : http://www.rpm.org/max-rpm-snapshot/s1-rpm-inside-scripts.html

myOperation=${1}

create_user ()
{
  grep -q "^<%= tomcat_user %>:" /etc/passwd \
  || useradd -d <%= prefix %> -c "user for apache-tomcat7" -M -s /bin/sh <%= tomcat_user %>
}

case ${myOperation} in
  1)             #Install RedHat
                 create_user
                 exit 0;;
  2)             #Upgrade RedHat
                 exit 0;;
  install)       #Debian:
                 #new-preinst install
                 #or new-preinst install <old-version>
                 [ "$2" == "" ] && create_user
                 exit 0;;
  upgrade)       #Debian:
                 #new-preinst upgrade <old-version>
                 exit 0;;
  abort-upgrade) #Debian:
                 #old-preinst abort-upgrade <new-version>
                 exit 0;;
  \?)            #Unknown
                 exit 1;;
  *)             exit 1;;
esac
exit 0
