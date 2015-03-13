# mkpackage-tomcat7
A project using easyfpm to package tomcat7 with the tar archive from archive.apache.org.

## How install this tool
You have to install easyfpm to make the package mkpackage-tomcat7.

To install easyfpm, install rubygem and then :

```
gem install easyfpm
```
or
```
gem install easyfpm --pre
```
if the first official version is not yet available

Once easyfpm is installed, you have to get mkpackage-tomcat7

Packaging the last version : 

```
git clone https://github.com/wanix/mkpackage-tomcat7.git
```
or

```
wget https://github.com/wanix/mkpackage-tomcat7/archive/v1.0.tar.gz -O /tmp/mkpackage-tomcat7-1.0.tar.gz
```

Once you have the directory mkpackage-tomcat7 and you are in it:

```
easyfpm --config-file _easyfpm/easyfpm.cfg --pkg-src-dir $PWD --pkg-output-dir /app/mypackages`
```

Your package is in /app/mypackages, install it on your system.

## How to use mkpackage-tomcat7

Once you have installed the package (see up), you have the help with the following command:
```
user@worstation:~$ /opt/mkpackage-tomcat7/bin/package-tomcat7.sh -h
  package-tomcat7.sh : download and package tomcat7 from archive.apache.org
    -h : help, this message
    -d : mandatory, tomcat7 version to download (ex 7.0.59)
    -c : facultative, easyfpm configfile to read, (default /opt/mkpackage-tomcat7/easyfpm-tomcat7/easyfpm.cfg)
    -t : facultative, temporary dir for download and extract (default /tmp)
    -o : facultative, output dir for packages (default /opt/mkpackage-tomcat7/var/packages), try to create it if non-existant.
    -e : facultative, easyfpm cmdline options

  examples:
    package-tomcat7.sh -d 7.0.59 -o /data/packages
    package-tomcat7.sh -d 7.0.59 -o /data/packages -e "--label tomcat7-deb"
    package-tomcat7.sh -d 7.0.59 -o /data/packages -e "--label tomcat7-deb,tomcat7-deb-docs,tomcat7-deb-manager"
```

Example of use:
```
user@worstation:~$ /opt/mkpackage-tomcat7/bin/package-tomcat7.sh -d 7.0.52 -o /app/perso-packages
  Retrieving apache-tomcat-7.0.52.tar.gz
  Retrieving apache-tomcat-7.0.52-fulldocs.tar.gz
Created package /tmp/easyfpm-output-dir20150313-27563-3bf319/apache-tomcat7_7.0.52-1_all.deb
Package moved to /app/perso-packages/apache-tomcat7_7.0.52-1_all.deb
no value for epoch is set, defaulting to nil
no value for epoch is set, defaulting to nil
Created package /tmp/easyfpm-output-dir20150313-27563-16gume/apache-tomcat7-7.0.52-1.noarch.rpm
Package moved to /app/perso-packages/apache-tomcat7-7.0.52-1.el6.noarch.rpm
Created package /tmp/easyfpm-output-dir20150313-27563-uurd44/apache-tomcat7-docs_7.0.52-1_all.deb
Package moved to /app/perso-packages/apache-tomcat7-docs_7.0.52-1_all.deb
no value for epoch is set, defaulting to nil
no value for epoch is set, defaulting to nil
Created package /tmp/easyfpm-output-dir20150313-27563-15duuls/apache-tomcat7-docs-7.0.52-1.noarch.rpm
Package moved to /app/perso-packages/apache-tomcat7-docs-7.0.52-1.el6.noarch.rpm
Created package /tmp/easyfpm-output-dir20150313-27563-1e5nuqd/apache-tomcat7-default_7.0.52-1_all.deb
Package moved to /app/perso-packages/apache-tomcat7-default_7.0.52-1_all.deb
no value for epoch is set, defaulting to nil
no value for epoch is set, defaulting to nil
Created package /tmp/easyfpm-output-dir20150313-27563-dcile4/apache-tomcat7-default-7.0.52-1.noarch.rpm
Package moved to /app/perso-packages/apache-tomcat7-default-7.0.52-1.el6.noarch.rpm
Created package /tmp/easyfpm-output-dir20150313-27563-1kcb9nz/apache-tomcat7-examples_7.0.52-1_all.deb
Package moved to /app/perso-packages/apache-tomcat7-examples_7.0.52-1_all.deb
no value for epoch is set, defaulting to nil
no value for epoch is set, defaulting to nil
Created package /tmp/easyfpm-output-dir20150313-27563-1shuk78/apache-tomcat7-examples-7.0.52-1.noarch.rpm
Package moved to /app/perso-packages/apache-tomcat7-examples-7.0.52-1.el6.noarch.rpm
Created package /tmp/easyfpm-output-dir20150313-27563-y43so1/apache-tomcat7-host-manager_7.0.52-1_all.deb
Package moved to /app/perso-packages/apache-tomcat7-host-manager_7.0.52-1_all.deb
no value for epoch is set, defaulting to nil
no value for epoch is set, defaulting to nil
Created package /tmp/easyfpm-output-dir20150313-27563-126552x/apache-tomcat7-host-manager-7.0.52-1.noarch.rpm
Package moved to /app/perso-packages/apache-tomcat7-host-manager-7.0.52-1.el6.noarch.rpm
Created package /tmp/easyfpm-output-dir20150313-27563-13stprq/apache-tomcat7-manager_7.0.52-1_all.deb
Package moved to /app/perso-packages/apache-tomcat7-manager_7.0.52-1_all.deb
no value for epoch is set, defaulting to nil
no value for epoch is set, defaulting to nil
Created package /tmp/easyfpm-output-dir20150313-27563-1ivatce/apache-tomcat7-manager-7.0.52-1.noarch.rpm
Package moved to /app/perso-packages/apache-tomcat7-manager-7.0.52-1.el6.noarch.rpm
```

which give us:
```
user@worstation:~$ ls /app/perso-packages/
apache-tomcat7_7.0.52-1_all.deb
apache-tomcat7-7.0.52-1.el6.noarch.rpm
apache-tomcat7-default_7.0.52-1_all.deb
apache-tomcat7-default-7.0.52-1.el6.noarch.rpm
apache-tomcat7-docs_7.0.52-1_all.deb
apache-tomcat7-docs-7.0.52-1.el6.noarch.rpm
apache-tomcat7-examples_7.0.52-1_all.deb
apache-tomcat7-examples-7.0.52-1.el6.noarch.rpm
apache-tomcat7-host-manager_7.0.52-1_all.deb
apache-tomcat7-host-manager-7.0.52-1.el6.noarch.rpm
apache-tomcat7-manager_7.0.52-1_all.deb
apache-tomcat7-manager-7.0.52-1.el6.noarch.rpm
```