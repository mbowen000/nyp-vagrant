########################
# IMAGE MAGICK INSTALLATION
########################

# this should download the tar archive from the imagemagick mirror to your home directory
# extracted it, and run the compilation
# 
# Compilation may take 3-5 minutes with a standard provisioned box
# 
# Author: Mike Bowen
# Copyright 2014 Technology Services Group

# IM_DOWNLOAD_URL=http://www.imagemagick.org/download/ImageMagick-6.8.9-7.tar.gz
# IM_PACKAGE=ImageMagick-6.8.9-7.tar.gz
# IM_EXTRACTED=ImageMagick-6.8.9-7

# cd $HOME

# if [ ! -f "$IM_PACKAGE" ]; then
# 	wget --quiet $IM_DOWNLOAD_URL
# 	tar -xf $IM_PACKAGE
# else
# 	echo "Already downloaded ImageMagick called: $IM_PACKAGE"
# fi

# # change to extracted dir
# cd $IM_EXTRACTED

# # configure and install
# ./configure
# sudo make install
# sudo ldconfig /usr/local/lib

# had some issues with this - prob need some prereqs etc. lets just apt
sudo apt-get -y install imagemagick