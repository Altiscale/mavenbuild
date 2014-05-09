mavenbuild
==========

An apache maven RPM packager to provide yum installation for apache-maven.
The default location is installed under /usr/share/apache-maven/ and you 
will find a link at /usr/bin/mvn

HOW-TO
======
Just simply run build.sh as a non-root user, the script will spin up the process 
and create a SRPM for mock. The final artifact will be the RPM to install.


