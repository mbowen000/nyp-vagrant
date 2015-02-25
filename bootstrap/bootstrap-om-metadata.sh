#!/bin/bash

################################
###### OM METADATA INGESTER ####
################################

SVN_DIR=$HOME/projects/nyphil/openmigrate
SVN_REPO=http://svn.tsgrp.com/repos/OpenMigrate/branches/clients/nyphil

# if we don't have the svn dir created we'll pull from svn
if [ ! -d "$SVN_DIR" ]; then
	#### PULL SVN ####
	svn co $SVN_REPO --username=$1 --password=$2 --non-interactive $SVN_DIR
else
	svn up --username=$1 --password=$2 --non-interactive $SVN_DIR
fi

###### BUILD OM #######
cd $SVN_DIR/code
chmod +x setenv-vagrant.sh
source setenv-vagrant.sh
ant distCore distAlfresco distNYPhil