## barbican-rabbitmq cookbook

Installs RabbitMQ for use with Barbican.  Sets up RabbitMQ for HA clustering.  Environment/deployment specific configurations should be set by wrapping this cookbook.

## Requirements

Requires RabbitMQ Cookbook rackspace-cookbooks/rabbitmq that contains a bugfix for restaring rabbit service with clustering

## Attributes

* `node['node_group']['tag']` - tag the node in the barbican cluster
* `node['node_group']['description']` - description of the node in the barbican cluster
* `node['rabbitmq']['erlang_cookie']` - this attribute should be overidden to set the cookie for cluster communication
* `node['barbican_rabbitmq']['user']` - username for rabbitmq
* `node['barbican_rabbitmq']['password']` - password for rabbitmq
* `node['barbican_rabbitmq']['host_ips']` - hash of hostname, ips for other rabbit nodes in the HA cluster

* `node['barbican_rabbitmq']['discovery']['search_query']` - query used for chef search to discover nodes
* `node['barbican_rabbitmq']['discovery']['ip_attribute']` - defines what attribute to use for determining the ip_address from the chef search.  For example, to use the ip address at node['rackspace']['private_ip'] you would set the value to 'rackspace.private_ip'. A nil value will use node['ipaddress'] by default


## Recipes

### default.rb

Install RabbitMQ, and configures for HA use.

"run_list": [
  "recipe[barbican-rabbitmq]"
]

### search_discovery.rb

Uses Chef search to identify other nodes in a RabbitMQ HA cluster.  This recipe runs the default recipe after populating the `node['barbican_rabbitmq']['host_ips']` attribute using Chef Search.

"run_list": [
  "recipe[barbican-rabbitmq]"
] 

## Author

Author:: Rackspace, Inc. (<cloudkeep@googlegroups.com>)
