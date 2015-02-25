# bootstrap commands that are needed to get yer project up and running

echo "Starting Provisioning for Client Specific Environment"
echo "All arguments available: $*" 
echo "SVN Username: $1"
echo "SVN Password: $2"

## THIS IS NYPHIL STUFF ##

########### SVN PULL DOWN ##############

### pull down stuff for the front-end
FRONT_END_CODE_DIR="$HOME/projects/nyphil/front-end-housekeeping"

if [ ! -d "$FRONT_END_CODE_DIR" ]; then
	mkdir -p $FRONT_END_CODE_DIR
	svn co http://svn.tsgrp.com/repos/NYPhilharmonic/Branches/front-end-housekeeping/ --username=$1 --password=$2 --non-interactive $FRONT_END_CODE_DIR
else
	svn up --username=$1 --password=$2 --non-interactive $FRONT_END_CODE_DIR
fi
########################################
########### PHP ENV SETUP ##############
########################################
# install php, apache, and the php module
sudo apt-get update
sudo apt-get -y install php5 libapache2-mod-php5 php5-curl apache2

# lets create a new site
cd /etc/apache2/sites-available
sudo cp /vagrant/bootstrap/client/sites-available/nyphil ./
# enable the new site
sudo a2ensite nyphil
# disable default site
sudo a2dissite default
# enable proxy modules
sudo a2enmod proxy
sudo a2enmod proxy_http
sudo a2enmod proxy_connect
sudo a2enmod rewrite

# restart apache (might give warnings though because we dont have our DocumentRoot directory created until we pull svn below)
sudo service apache2 restart

# wow, now we're getting somewhere - you should be able to go to localhost:1337 and see nyphil's front end...

########################################
# ########## SOLR INSTALL ##############
########################################

# # create a new solr directory
# mkdir -p $HOME/apache/solr
# cd $HOME/apache/solr

# # download solr archive (1.4.1 for nyphil)
# echo "Downloading SOLR.. please wait."
# #wget --quiet http://archive.apache.org/dist/lucene/solr/1.4.1/apache-solr-1.4.1.tgz
# tar -xvf apache-solr-1.4.1.tgz

# # set up a dev solr configuration with multiple cores
# cd $HOME/apache/solr/apache-solr-1.4.1

#### SET UP SOLR TOMCAT ####
APACHE_DIR="$HOME/apache"
TOMCAT_DOWNLOAD_LINK="http://www.us.apache.org/dist/tomcat/tomcat-6/v6.0.41/bin/apache-tomcat-6.0.41.tar.gz"
TOMCAT_TAR="apache-tomcat-6.0.41.tar.gz"
TOMCAT_FINAL_DIR_SOLR="$HOME/apache/apache-tomcat-solr"

if [ ! -d "$APACHE_DIR" ]; then
	mkdir $HOME/apache
fi	

# get to it
cd $APACHE_DIR

#download and extract tomcat
if [ ! -d "$TOMCAT_FINAL_DIR_SOLR" ]; then
	wget --quiet $TOMCAT_DOWNLOAD_LINK
	tar -xvf apache-tomcat-6.0.41.tar.gz
	mv apache-tomcat-6.0.41 apache-tomcat-solr

	# auto-start this tomcat
	sudo bash -c "echo 'export JAVA_HOME=\"/home/vagrant/java/jdk1.6.0_45\"' >> /etc/init.d/vagrantstart" # needs java home
	sudo bash -c "echo 'export JAVA_OPTS=\"$JAVA_OPTS -D.solr.solr.home=/home/vagrant/apache/apache-tomcat-solr/conf\"' >> /etc/init.d/vagrantstart" # needs java opts
	sudo bash -c "echo 'su - vagrant -m -c \"/home/vagrant/apache/apache-tomcat-solr/bin/startup.sh\"' >> /etc/init.d/vagrantstart"

	# sed replace the server port for tomcat (we can't use 8080)
	sed -i 's/port\=\"8080\"/port\=\"8983\"/' $HOME/apache/apache-tomcat-solr/conf/server.xml
	sed -i 's/port\=\"8005\"/port\=\"8905\"/' $HOME/apache/apache-tomcat-solr/conf/server.xml
	sed -i 's/redirectPort\=\"8443\"/redirectPort\=\"8993\"/' $HOME/apache/apache-tomcat-solr/conf/server.xml
fi

# get to it
cd $TOMCAT_FINAL_DIR_SOLR

# build the solr war (copy in source from svn and ant dist)
### we're not building this now.. we can use the existing build... + solr 1.4.1 isn't building because of bad dependency links hardcoded

# copy in our configuration / war
cp -rf $FRONT_END_CODE_DIR/solr/multicore/* $TOMCAT_FINAL_DIR_SOLR/conf/
cp -rf $FRONT_END_CODE_DIR/solr/dist/solr.war $TOMCAT_FINAL_DIR_SOLR/webapps/
# set solr.home (and persist in startup script)
export JAVA_OPTS="$JAVA_OPTS -Dsolr.solr.home=/home/vagrant/apache/apache-tomcat-solr/conf"
export JAVA_HOME="$HOME/java/jdk1.6.0_45"

# start up tomcat
$HOME/apache/apache-tomcat-solr/bin/./startup.sh