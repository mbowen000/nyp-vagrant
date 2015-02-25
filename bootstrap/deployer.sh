#!/bin/bash
### PROVISIONING SCRIPT FOR TSG - WILL START UP WHEN YOU RUN 'vagrant up' or 'vagrant up --provision' ###

echo "Starting Redeployer Provisioning Script"
echo "All arguments available: $*" 

######### LETS GET SOME AMPs GOING ##########

ALFRESCO_HOME=$HOME/alfresco/alfresco-dev
AMP_DIR=$HOME/projects/nyphil/nyphilAmp


# shut down alfresco
echo "Shutting down tomcat, please wait..."
$ALFRESCO_HOME/./alfresco.sh stop tomcat

# check out the amp from svn
if [ ! -d "$AMP_DIR" ]; then
	svn co http://svn.tsgrp.com/repos/AlfrescoModules/trunk/clients/nyphilAmp/ --username=$1 --password=$2 --non-interactive $AMP_DIR
else
	# change to the amp dir before updating
	cd $AMP_DIR
	svn up --username=$1 --password=$2 --non-interactive
fi

# just change to the amp dir regardless
cd $AMP_DIR

# build the amp with the overlay specified for vagrant
ant package-amp -Denv=vagrant

# copy the built amp to the amps directory
cp $AMP_DIR/build/dist/tsgrp-nyphil.amp $ALFRESCO_HOME/amps/

# backups should already be created called alfresco.war.cleanbak and share.war.cleanbak, lets start w/ those
rm -rf $ALFRESCO_HOME/tomcat/webapps/alfresco.war
rm -rf $ALFRESCO_HOME/tomcat/webapps/share.war
cp $ALFRESCO_HOME/tomcat/webapps/alfresco.war.cleanbak $ALFRESCO_HOME/tomcat/webapps/alfresco.war
cp $ALFRESCO_HOME/tomcat/webapps/share.war.cleanbak $ALFRESCO_HOME/tomcat/webapps/share.war

# run the amp deployer (w/ yes so execution will continue on prompt for any key..)
yes | $HOME/alfresco/alfresco-dev/bin/./apply_amps.sh -force

# start alfresco back up
echo "Starting tomcat back up, please wait..."
$HOME/alfresco/alfresco-dev/./alfresco.sh start