# java options
node.default['java']['install_flavor'] = 'oracle'
node.default['java']['jdk_version'] = 7
node.default['java']['oracle']['accept_oracle_download_terms'] = true

# solr
node.default['nyphil']['solr']['github_repo'] = "https://github.com/mbowen000/solr.git"
node.default['nyphil']['solr']['code_directory'] = "/home/vagrant/code/solr"
node.default['nyphil']['solr']['home_dir'] = "/var/lib/solr"

# tomcat is configured in the vagrantfile for a couple props because of attribute probs in wrapper cookbooks
node.default['tomcat']['java_options'] = "-Xmx256M -Djava.awt.headless=true -Dsolr.solr.home=#{node['nyphil']['solr']['home_dir']}"
node.default['tomcat']['port'] = 8984