#!/usr/bin/env bash
### PROVISIONING SCRIPT FOR TSG - WILL START UP WHEN YOU RUN 'vagrant up' or 'vagrant up --provision' ###

echo "Starting Provisioning for TSG's Environment"
echo "All arguments available: $*" 

#########################
### SOFTWARE INSTALLS ###
#########################
# Core Software Installs (-y makes them answer all prompts with yes)
apt-get update
apt-get install -y vim
apt-get install -y screen
#apt-get install -y subversion # we need to get this from source, because the apt repos are old
apt-get install -y git
apt-get install -y unzip

# Subversion (1.8)
echo "deb http://opensource.wandisco.com/ubuntu precise svn18" >> /etc/apt/sources.list.d/subversion18.list
wget -q http://opensource.wandisco.com/wandisco-debian.gpg -O- | sudo apt-key add -
apt-get update
apt-get install -y subversion

#########################
##### DIRS/FILES  ######
#########################
# Core directories (should be universal)


############################
# Create core startup script
############################
# create new startup script for all vagrant stuff we want to start
sudo touch /etc/init.d/vagrantstart
sudo echo "#!/bin/bash" >> /etc/init.d/vagrantstart
sudo chmod +x /etc/init.d/vagrantstart 
# be sure to add it to the startup list (this is debian specific)
sudo update-rc.d vagrantstart defaults