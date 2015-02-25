#!/bin/bash

# Provisioning script to install JRebel
# This will install a set version.  Add a new version and change the properies to reflect if you want to upgrade.
# We're not auto-downloading from their site because they have a weird cookie download system for marketing or something.  Jrebel and their marketing...
# So we've just included the zip in the bootstrap

JREBEL_ZIP=/vagrant/bootstrap/jrebel/jrebel-5.6.1-nosetup.zip
JREBEL_INSTALL_DIR=$HOME/java
JREBEL_FINAL_DIR=$HOME/java/jrebel
PROPS_FILE_LOC=/vagrant/bootstrap/jrebel/jrebel.properties

if [ ! -d "$JREBEL_FINAL_DIR" ]; then
	unzip $JREBEL_ZIP -d $JREBEL_INSTALL_DIR
else
	echo "It looks like JRebel is already installed in the directory: $JREBEL_FINAL_DIR .. Please remove that directory if you would like re-install using this provision script"
fi

export REBEL_HOME="$JREBEL_FINAL_DIR"
echo "REBEL_HOME=$JREBEL_FINAL_DIR" >> /home/vagrant/.bashrc

# Todo: License info needs to be collected from the user for this script
# lets copy a file so the user can customize
if [ ! -d "$HOME/.jrebel" ]; then
	mkdir "$HOME/.jrebel"
fi
cp $PROPS_FILE_LOC $HOME/.jrebel/jrebel.properties

#### MODIFYING Alfresco w/ JRebel Support ####
ALFRESCO_HOME=$HOME/alfresco/alfresco-dev
cd $ALFRESCO_HOME
cp tomcat/scripts/ctl.sh tomcat/scripts/ctl.sh.bak
sed "s/JAVA_OPTS=\"/JAVA_OPTS=\"-Xverify:none -javaagent:\/home\/vagrant\/java\/jrebel\/jrebel.jar /g" <tomcat/scripts/ctl.sh >tomcat/scripts/modified.sh
rm tomcat/scripts/ctl.sh
mv tomcat/scripts/modified.sh tomcat/scripts/ctl.sh
chmod +x tomcat/scripts/ctl.sh