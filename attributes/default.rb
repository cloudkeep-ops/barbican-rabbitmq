
#The erlang cookie, that must be the same across all cluster nodes.  
#The cookie should probably be overriden in a wrapping cookbook to 
#set unique cookies per environment
default['rabbitmq']['erlang_cookie'] = 'queue-solo'

#Tag the node in the barbican cluster
default['node_group']['tag'] = 'queue'
default['node_group']['description'] = 'Barbican Queue Node'

default['barbican_rabbitmq']['user'] = 'guest'
default['barbican_rabbitmq']['password'] = 'guest'

#Hash of hostname, ips for other rabbit nodes in the HA cluster
default['barbican_rabbitmq']['host_ips'] = {node['hostname'] => node['ipaddress']}

#Query used for chef search to discover nodes
default['barbican_rabbitmq']['discovery']['search_query'] = "node_group_tag:#{node['node_group']['tag']} AND chef_environment:#{node.chef_environment}"
#defines what attribute to use for determining the ip_address from the chef search
#for example node['rackspace']['private_ip'] would be defined as = 'rackspace.private_ip'
# a nil value will use node['ip_address'] by default
default['barbican_rabbitmq']['discovery']['ip_attribute'] = nil
