#
# Cookbook Name:: barbican-rabbitmq
# Recipe:: default
#
# Copyright (C) 2013 Rackspace, Inc.
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#    http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Note that the yum repository configuration used here was found at this site:
#   http://docs.opscode.com/resource_cookbook_file.html
#

# Configure host table as needed by RabbitMQ clustering:
rabbit_hosts_entries = []

#   - Build cluster host entries.
node['barbican_rabbitmq']['host_ips'].each do |host, ip|
  rabbit_hosts_entries.push("#{ip}\t#{host}\n")
end

#   - Write the hosts file with host entries.
template "/etc/hosts" do
  source "hosts.erb"
  variables(
    :rabbit_ips_hostnames => rabbit_hosts_entries
  )
end

# Configure RabbitMQ:
#    - Default to true for clustered rabbit.
node.set["rabbitmq"]["cluster"] = true
#    - Create string of cluster nodes.
hosts = node['barbican_rabbitmq']['host_ips'].keys
hosts.sort! 
node.set['rabbitmq']['cluster_disk_nodes'] = hosts.map{|n| "rabbit@#{n}"}
Chef::Log.debug "rabbitmq cluster string: #{node['rabbitmq']['cluster_disk_nodes']}"
Chef::Log.debug "rabbitmq cookie: #{node['rabbitmq']['erlang_cookie']}"

include_recipe "rabbitmq"

if node['barbican_rabbitmq']['databag_name']
  rabbitmq_bag = data_bag_item(node['barbican_rabbitmq']['databag_name'], 'rabbitmq')
  vhost = rabbitmq_bag['vhost']
  username = rabbitmq_bag['username']
  password = rabbitmq_bag['password']
  vhost_permissions = rabbitmq_bag['vhost_permissions']
  rabbitmq_user 'guest' do
    action :delete
  end
else
  vhost = node['barbican_rabbitmq']['vhost']
  username = node['barbican_rabbitmq']['user']
  password = node['barbican_rabbitmq']['password']
  vhost_permissions = node['barbican_rabbitmq']['vhost_permissions']
end

rabbitmq_vhost vhost do
  action :add
end

rabbitmq_user username do
  password password 
  action :add
end

rabbitmq_user username do
  vhost vhost
  permissions vhost_permissions
  action :set_permissions
end

rabbitmq_user username do
  tag 'administrator'
  action :set_tags
end

rabbitmq_policy "ha-all" do
  pattern "^(?!amq\\.).*"
  params "ha-mode" => "all"
  priority 1
  action :set
end

include_recipe "rabbitmq::mgmt_console"
