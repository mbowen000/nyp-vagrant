#
# Cookbook Name:: nyphil
# Recipe:: frontend
#
# Copyright (C) 2015 New York Philharmonic Digital Archives
#
# All rights reserved - Do Not Redistribute
#

Chef::Log.info('Using chef recipe nyphil::frontend...')

# include the apt recipe to refresh apt-sources prior to running this script (https://github.com/opscode-cookbooks/apt)
include_recipe "apt::default"

# install apache w/ default settings (any additional configuraiton should be placed in an attributes file!)
include_recipe "apache2"

# disable default site
apache_site '000-default' do
  enable false
end

# create our site
template "#{node['apache']['dir']}/sites-available/nyphil.conf" do
  source 'apache/nyphil.conf.erb'
  notifies :restart, 'service[apache2]'
end

# enable our site
apache_site 'nyphil' do 
	enable true
end

# enable additional modules required
apache_module 'proxy' do
	enable true
end
apache_module 'proxy_http' do
	enable true
end

# TODO: Add checkout of front-end code from github hereabouts.. note that it would be best if we just got the front-end site code not all those other repos.. so talk to 
# mitch about not making the front-end repo the same as the solr-repo and all those other things
# great time to do some repo cleaning!

