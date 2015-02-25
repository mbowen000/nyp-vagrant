#!/bin/bash

##########################
# KAKADU INSTALLATION
##########################

# This script assumes that you have a kakadu zip file in the bootstrap/client/kakadu folder in the vagrant mounted share
# It will then take that zip, extract it, and run make to compile it.
# 
# Compilation may take a few minutes so be patient.
# 
# Author: Mike Bowen
# Copyright 2014 Technology Services Group

KAKADU_DIR=$HOME/kakadu
KAKADU_ZIP=v7_4-01521E.zip
KAKADU_EXTRACTED=v7_4-01521E

# we need essential build tools to use 'make'
sudo apt-get -yq install build-essential

if [ ! -d "$KAKADU_DIR" ]; then
	mkdir $KAKADU_DIR
else
	echo "Kakadu Directory already created, remove if you would like to restart this process..."
fi

# change to the kdu dir
cd $KAKADU_DIR

if [ ! -f "$KAKADU_ZIP" ]; then
	cp /vagrant/bootstrap/client/kakadu/$KAKADU_ZIP ./
else
	echo "Kakadu zip already found in directory.. skipping copy."
fi

if [ ! -d "$KAKADU_EXTRACTED" ]; then
	unzip -q $KAKADU_ZIP
else
	echo "Kakadu zip already extracted, not re-unzipping"
fi

# change to the extracted dir
cd $KAKADU_EXTRACTED/make

# make kdu
make -f Makefile-Linux-x86-64-gcc

# go back up
cd ../

# we need to copy and refresh our libs
sudo cp ./lib/Linux-x86-64-gcc/* /usr/local/lib/
# refresh
sudo bash -c "ldconfig"

# add env vars
# (You may have to re-login to ssh for this to work... or run this script w/ 'source kakadu-deployer.sh')
echo "export PATH=$KAKADU_DIR/$KAKADU_EXTRACTED/bin/Linux-x86-64-gcc:$PATH" >> $HOME/.bashrc
export PATH="$KAKADU_DIR/$KAKADU_EXTRACTED/bin/Linux-x86-64-gcc:$PATH"