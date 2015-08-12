#!/bin/bash

# TBD: honor system pre-defined property/variable files from 
# /etc/hadoop/ and other /etc config for spark, hdfs, hadoop, etc

if [ "x${JAVA_HOME}" = "x" ] ; then
  export JAVA_HOME=/usr/java/default
fi
if [ "x${MAVEN_HOME}" = "x" ] ; then
  export MAVEN_HOME=/opt/apache-maven
fi
if [ "x${M2_HOME}" = "x" ] ; then
  export M2_HOME=/opt/apache-maven
fi
if [ "x${M2}" = "x" ] ; then
  export M2=${M2_HOME}/bin
fi
if [ "x${MAVEN_OPTS}" = "x" ] ; then
  export MAVEN_OPTS="-Xmx4096m -XX:MaxPermSize=1024m"
fi

export PATH=$PATH:$M2_HOME/bin:$JAVA_HOME/bin

# Define defau;t spark uid:gid and build version
# WARNING: the YOURCOMPONENT_VERSION branch name does not align with the Git branch name branch-0.8 / trunk
if [ "x${YOURCOMPONENT}" = "x" ] ; then
  export YOURCOMPONENT=apache-maven
fi

if [ "x${YOURCOMPONENT_VERSION}" = "x" ] ; then
  export YOURCOMPONENT_VERSION=3.2.1
fi
if [ "x${ALTISCALE_RELEASE}" = "x" ] ; then
  export ALTISCALE_RELEASE=3.0.0
fi

# The build time here is part of the release number
# It is monotonic increasing
BUILD_TIME=$(date +%Y%m%d%H%M)
export BUILD_TIME




