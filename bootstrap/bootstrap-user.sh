# bootstrap commands that should be ran as vagrant user# bootstrap commands that should be ran as vagrant user

echo "Starting Provisioning for Users Environment"
echo "All arguments available: $*" 
echo "SVN Username: $1"
echo "SVN Password: $2"

echo "# Custom TSG Provisioning Modified this file! Changes to follow..." >> $HOME/.bashrc

#############################
### JAVA JDK INSTALLATION ###
#############################
# Make sure you change your java file name here:
JAVA_INSTALLER="jdk-6u45-linux-x64.bin" # this should match the name in the end of the download link
JAVA_INFLATED_DIR="jdk1.6.0_45" # this is the name of the directory that gets inflated by the .bin / .tar.gz installer (will hopefully be consistent across versions but you might have to test locally if changing here)
JAVA_DOWNLOAD_LINK="http://download.oracle.com/otn-pub/java/jdk/6u45-b06/jdk-6u45-linux-x64.bin"
# other java versions (uncomment)
# http://download.oracle.com/otn-pub/java/jdk/7u60-b19/jdk-7u60-linux-x64.tar.gz
# http://download.oracle.com/otn-pub/java/jdk/8u5-b13/jdk-8u5-linux-x64.tar.gz
echo "Using java download location: $JAVA_DOWNLOAD_LINK"

# See below link for info about how to get around Oracles stupid license to wget
# http://stackoverflow.com/questions/10268583/how-to-automate-download-and-installation-of-java-jdk-on-linux
# get jdk 6

# make a java folder in $HOME and change into it
mkdir -p $HOME/java
cd $HOME/java
# Do the download, bypassing the cookie
wget --quiet --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" $JAVA_DOWNLOAD_LINK
# Change permissions and inflate
chmod 777 $JAVA_INSTALLER
sh $JAVA_INSTALLER

# We've got to add some classpath variables to the path
# notice the double quotes around the echo... with single quotes it won't print the $ENV variables
echo "export JAVA_HOME=/home/vagrant/java/$JAVA_INFLATED_DIR" >> $HOME/.bashrc
# this one we literally want to print $JAVA_HOME, not the env variable
echo 'export PATH=$PATH:$JAVA_HOME/bin' >> $HOME/.bashrc

###########################
##### ANT INSTALLATION ####
###########################
ANT_INSTALLER="apache-ant-1.9.4-bin.tar.gz"
ANT_INFLATED_DIR="apache-ant-1.9.4"
ANT_DOWNLOAD_LINK="http://www.apache.org/dist/ant/binaries/apache-ant-1.9.4-bin.tar.gz"

echo "Using ant download location: $ANT_DOWNLOAD_LINK"
cd $HOME/java
wget --quiet $ANT_DOWNLOAD_LINK
tar -xvf $ANT_INSTALLER
# set some env variables
export ANT_HOME=$HOME/java/$ANT_INFLATED_DIR
echo "export ANT_HOME=$HOME/java/$ANT_INFLATED_DIR" >> $HOME/.bashrc
# this one we literally want to print $GRADLE_HOME, not the env variable
echo 'export PATH=$PATH:$ANT_HOME/bin' >> $HOME/.bashrc

###########################
### GRADLE INSTALLATION ###
###########################
GRADLE_DOWNLOAD_LINK="https://services.gradle.org/distributions/gradle-1.9-bin.zip"
GRADLE_INFLATED_DIR="gradle-1.9"
GRADLE_ZIP_PACKAGE="gradle-1.9-bin.zip"

echo "Using Gradle Download Location: $GRADLE_DOWNLOAD_LINK"

cd $HOME/java
wget --quiet $GRADLE_DOWNLOAD_LINK
unzip $GRADLE_ZIP_PACKAGE

# Add GRADLE_HOME and binary to path
echo "export GRADLE_HOME=/home/vagrant/java/$GRADLE_INFLATED_DIR" >> $HOME/.bashrc
# this one we literally want to print $GRADLE_HOME, not the env variable
echo 'export PATH=$PATH:$GRADLE_HOME/bin' >> $HOME/.bashrc

#############################
### ALFRESCO INSTALLATION ###
#############################
ALFRESCO_DOWNLOAD_LINK="http://10.1.1.66/install/Alfresco/alfresco-enterprise-4.1.5/alfresco-enterprise-4.1.5-installer-linux-x64.bin"
ALFRESCO_INSTALLER_NAME="alfresco-enterprise-4.1.5-installer-linux-x64.bin"

# set some req'd env vars for postgres.. these are also set in the user's bashrc script!
export LANGUAGE=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
echo "export LANGUAGE=en_US.UTF-8" >> $HOME/.bashrc
echo "export LANG=en_US.UTF-8" >> $HOME/.bashrc
echo "export LC_ALL=en_US.UTF-8" >> $HOME/.bashrc

mkdir -p $HOME/alfresco
cd $HOME/alfresco
echo "Please wait, downloading alfresco...this could take a couple minutes..."
wget --quiet $ALFRESCO_DOWNLOAD_LINK
chmod 777 $ALFRESCO_INSTALLER_NAME

#run the alfresco installer w/ options file
./$ALFRESCO_INSTALLER_NAME --optionfile /vagrant/bootstrap/alfresco-install-opts

#add a line to our startup to start alfresco 
#echo "/home/vagrant/alfresco/alfresco-dev/./alfresco.sh start" >> $HOME/.bashrc
#we want this on startup not login
sudo bash -c "echo 'su - vagrant -m -c \"/home/vagrant/alfresco/alfresco-dev/alfresco.sh start\"' >> /etc/init.d/vagrantstart"

####### POST INSTALL CLEANUP ETC ###########
# try to shut alfresco down (for now, we need to install some amps and make some backups)
cd /home/vagrant/alfresco/alfresco-dev
# ./alfresco.sh stop tomcat
# # try to remove
# sudo rm -rf tomcat/webapps/alfresco
# sudo rm -rf tomcat/webapps/share
# # make WAR backups
sudo cp tomcat/webapps/alfresco.war tomcat/webapps/alfresco.war.cleanbak
sudo cp tomcat/webapps/share.war tomcat/webapps/share.war.cleanbak

############################
##### ALFRESCO SDK #########
############################
ALFRESCO_SDK_DOWNLOAD_LINK="http://10.1.1.66/install/Alfresco/alfresco-enterprise-4.1.5/alfresco-enterprise-sdk-4.1.5.zip"
ALFRESCO_SDK_PACKAGE_NAME="alfresco-enterprise-sdk-4.1.5.zip"
ALFRESCO_SDK_EXTRACTED_NAME="alfresco-enterprise-sdk-4.1.5"

mkdir $HOME/alfresco/sdks
cd $HOME/alfresco/sdks
wget --quiet $ALFRESCO_SDK_DOWNLOAD_LINK
unzip -d $ALFRESCO_SDK_EXTRACTED_NAME $ALFRESCO_SDK_PACKAGE_NAME
# Set env vars for AMP builds to know
export ALFRESCO_SDK=$HOME/alfresco/sdks/$ALFRESCO_SDK_EXTRACTED_NAME
echo "export ALFRESCO_SDK=$HOME/alfresco/sdks/$ALFRESCO_SDK_EXTRACTED_NAME" >> $HOME/.bashrc