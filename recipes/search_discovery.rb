#
# Cookbook Name:: barbican-rabbitmq
# Recipe:: search_discovery
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

[Chef::Recipe, Chef::Resource].each { |l| l.send :include, ::Extensions }

unless Chef::Config[:solo]
  #search chef server for queue nodes with given query string
  q_nodes = search(:node, node['barbican_rabbitmq']['discovery']['search_query'])
  hosts = []
  ips = []

  unless q_nodes.empty?
    for q_node in q_nodes
      hosts.push(q_node['hostname'])
      ips.push(select_ip_attribute(q_node, node['barbican_rabbitmq']['discovery']['ip_attribute']))          
    end
  else
    Chef::Log.info 'No other queue nodes found to cluster with.'  
  end

  #create a hash of hostname to ip mappings
  host_ips = Hash[hosts.zip(ips)]
  #make sure that the current node is included in the hash
  host_ips.merge!({node['hostname'] => select_ip_attribute(node, node['barbican_rabbitmq']['discovery']['ip_attribute'])})

  #populate the node attribute used for defining hostname/ips for HA cluster
  node.set['barbican_rabbitmq']['host_ips'] = host_ips
end

include_recipe 'barbican-rabbitmq'
