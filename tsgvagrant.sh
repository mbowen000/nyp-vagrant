#!/bin/bash

# make sure the user does not have any code directory, this is a shared directory that needs to be clean for a reprovision
if [ -d "./code" ]; then
	echo "It appears that you have provisioned a machine before, and it has left behind a /code folder! Please remove it before re-provisioning to avoid collision, then re-run this script."
else

	# Prompt user for their SVN credentials that will be used to pass to the bootstrap.sh script
	read -p "Please enter your SVN username: " username
	read -p "And your SVN password, please: " password

	if [ -z "$username" ] || [ -z "$password" ]
		then 
			echo "No Username or Password Supplied.. this is required."
			exit 1
	fi

	export VAGRANT_ARGS="$username $password"

	# call vagrant passing in any supplied args the user may have put on this script
	vagrant up $*
fi