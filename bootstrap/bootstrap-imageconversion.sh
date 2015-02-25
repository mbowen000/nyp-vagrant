#!/bin/bash

################################
###### OM IMAGE CONVERTER ######
################################

TOMCAT_DIR=$HOME/apache/apache-tomcat-conversion
SVN_DIR=$HOME/projects/nyphil/image-converter


if [ ! -d "$TOMCAT_DIR" ]; then
	echo "Tomcat for image converter not found, getting apache and setting up.."

	# if the apache dir doesnt exist yet
	if [ ! -d "$HOME/apache" ]; then
		mkdir -p $HOME/apache
	fi

	cd $HOME/apache

	if [ ! -f "apache-tomcat-6.0.41.tar.gz" ]; then
		# download apache
		echo "Downloading apache.. please wait.."
		wget --quiet https://archive.apache.org/dist/tomcat/tomcat-6/v6.0.41/bin/apache-tomcat-6.0.41.tar.gz
	fi

	# extract and rename
	tar -xvf apache-tomcat-6.0.41.tar.gz
	mv apache-tomcat-6.0.41 $TOMCAT_DIR

	# adjust some ports
	sed -i 's/port\=\"8080\"/port\=\"18080\"/' $TOMCAT_DIR/conf/server.xml
	sed -i 's/port\=\"8005\"/port\=\"18005\"/' $TOMCAT_DIR/conf/server.xml
	sed -i 's/redirectPort\=\"8443\"/redirectPort\=\"18443\"/' $TOMCAT_DIR/conf/server.xml
	sed -i 's/port\=\"8009\"/port\=\"18009\"/' $TOMCAT_DIR/conf/server.xml

fi

# if we don't have the svn dir created we'll pull from svn
if [ ! -d "$SVN_DIR" ]; then
	#### PULL SVN ####
	svn co http://svn.tsgrp.com/repos/OpenMigrate/branches/clients/nyphil-imageconversion/openmigrate-mvc --username=$1 --password=$2 --non-interactive $SVN_DIR
else
	svn up --username=$1 --password=$2 --non-interactive $SVN_DIR
fi

####### BUILD AND DEPLOY #######

# shut down tomcat if its running
$TOMCAT_DIR/bin/shutdown.sh

cd $SVN_DIR
gradle war -Poverlay=vagrant

# copy to tomcat
cp -f build/libs/imageconverter.war $TOMCAT_DIR/webapps
rm -rf $TOMCAT_DIR/webapps/imageconverter

$TOMCAT_DIR/bin/startup.sh