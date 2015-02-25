#!/bin/bash
# solr deployer for nyphil

TOMCAT_HOME=$HOME/apache/apache-tomcat-solr

# copy in stuff from svn to solr
cp -rf $HOME/projects/nyphil/front-end-housekeeping/solr/multicore/* $TOMCAT_HOME/conf/

# restart apache-tomcat-solr
$TOMCAT_HOME/bin/shutdown.sh
$TOMCAT_HOME/bin/startup.sh