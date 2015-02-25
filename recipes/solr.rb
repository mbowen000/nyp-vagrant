#
# Cookbook Name:: nyphil
# Recipe:: solr
#
# Copyright (C) 2015 New York Philharmonic Digital Archives
#
# All rights reserved - Do Not Redistribute
#

include_recipe 'apt'
include_recipe 'java'
include_recipe 'tomcat'
include_recipe 'ant'
include_recipe 'git'

# ##############################################
# Installing SOLR Sources and Building Custom WAR 
# (This is not finished - Mike doesnt have time)
# ##############################################
# solr_filename = "solr-4.10.2-src.tgz"
# solr_filepath = "#{Chef::Config[:file_cache_path]}/#{solr_filename}"
# solr_remotepath = "http://archive.apache.org/dist/lucene/solr/4.10.2/solr-4.10.2-src.tgz"
# solr_extractpath = "#{Chef::Config['file_cache_path']}/#{solr_filename}-extracted"

# Chef::Log.info('Extracting solr')
# Chef::Log.info("Chef cache dir: #{Chef::Config['file_cache_path']}")
# remote_file solr_filepath do
#   source solr_remotepath
# end

# bash "extract_solr" do 
# 	cwd ::File.dirname(solr_filepath)
# 	code <<-EOH
# 		mkdir -p #{solr_extractpath}
# 		tar -xvf #{solr_filename} -C #{solr_extractpath}
# 	EOH
# 	not_if { ::File.exists?(solr_extractpath) }
# end


# ##############################################
# Copy WAR Into Tomcat7 From Git (Project Should be hosated and defined)
# ##############################################

# define some necessary vars
solr_code_location = "/home/vagrant/code/solr"
solr_war_location = "#{solr_code_location}/dist"
solr_war_name = "solr-4.10.2-SNAPSHOT.war"
solr_war_rename = "solr.war"
solr_webapps_location = "#{node['tomcat']['webapp_dir']}"
solr_webapps_location_check = "#{solr_webapps_location}/#{solr_war_rename}"
solr_lib_location = "#{node['tomcat']['lib_dir']}"
solr_log4j_name = "log4j.properties"
solr_log4j_location_check = "#{solr_webapps_location}/#{solr_log4j_name}"
solr_lib_deps_location = "#{solr_war_location}/lib"
solr_config_location = "#{solr_code_location}/multicore"
solr_home = "#{node['nyphil']['solr']['home_dir']}"

# create a folder for our code (if its not created already)
directory "/home/vagrant/code" do 
	owner "vagrant"
	group "vagrant"
	mode "0755"
	action :create
end

# check out solr code (todo: move repo!)
git "#{node['nyphil']['solr']['code_directory']}" do
  repository "#{node['nyphil']['solr']['github_repo']}"
  revision "master"
  action :sync
end

# create a solr data directory (if not created)
directory "#{solr_home}" do
	owner "#{node['tomcat']['user']}"
	group "#{node['tomcat']['group']}"
	mode "0755"
	action :create
end

# define tomcat7 service - we need it so we can restart it
service "tomcat7" do 
	supports :restart => true
end

Chef::Log.info("Solr war dir is:");
Chef::Log.info("#{node['tomcat']['webapp_dir']}")

bash "move_solr_war" do
	cwd solr_war_location
	code <<-EOH
		cp #{solr_war_name} #{solr_webapps_location}/#{solr_war_rename}
	EOH
	not_if { ::File.exists?(solr_webapps_location_check) }
	notifies :restart, resources(:service => 'tomcat7')
end

bash "move_log4j" do
	cwd solr_war_location
	code <<-EOH
		cp #{solr_log4j_name} #{solr_lib_location}
	EOH
	not_if { ::File.exists?(solr_log4j_location_check) }
	notifies :restart, resources(:service => 'tomcat7')
end

bash "move_lib_deps" do 
	cwd solr_lib_deps_location
	code <<-EOH
		cp *.jar #{solr_lib_location}
	EOH
	notifies :restart, resources(:service => 'tomcat7')
end

bash "move_solr_home" do
	cwd solr_config_location
	code <<-EOH
		cp -rf * #{solr_home}
		chown -R #{node['tomcat']['user']}:#{node['tomcat']['group']} #{solr_home}/*
	EOH
	notifies :restart, resources(:service => 'tomcat7')
end