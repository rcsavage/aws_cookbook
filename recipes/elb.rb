#
# Cookbook Name:: aws_sdk
# Recipe:: elb
#
# Copyright 2014, digitaldreams 
#
# All rights reserved - Do Not Redistribute


# Install required packages for use with aws_sdk
# This is the RPM Check Section
execute "digitaldreams-rpm-check: nokogiri-1.6.2.1-1" do
  command "rpm -ivh --nodeps --force http://yumrepo.digitaldreams.com/common/rubygem-nokogiri-1.6.2.1-1.x86_64.rpm"
  not_if "rpm -qa | grep -q 'rubygem-nokogiri-1.6.2.1-1.x86_64'"
  action :nothing
end.run_action(:run)
execute "digitaldreams-rpm-check: mini_portile-0.6.0-1" do
  command "rpm -ivh --nodeps --force http://yumrepo.digitaldreams.com/common/rubygem-mini_portile-0.6.0-1.noarch.rpm"
  not_if "rpm -qa | grep -q 'rubygem-mini_portile-0.6.0-1.noarch'"
  action :nothing
end.run_action(:run)
execute "digitaldreams-rpm-check: aws-sdk-1.42.0-1" do
  command "rpm -ivh --nodeps --force http://yumrepo.digitaldreams.com/common/rubygem-aws-sdk-1.42.0-1.noarch.rpm"
  not_if "rpm -qa | grep -q 'rubygem-aws-sdk-1.42.0-1.noarch'"
  action :nothing
end.run_action(:run)

# This is the GEM Check Section
execute "digitaldreams-gem-check: nokogiri-1.6.2.1-1" do
  command "rpm -ivh --nodeps --force http://yumrepo.digitaldreams.com/common/rubygem-nokogiri-1.6.2.1-1.x86_64.rpm"
  not_if "/opt/chef/embedded/bin/gem list --local nokogiri|grep -q nokogiri"
  action :nothing
end.run_action(:run)
execute "digitaldreams-gem-check: mini_portile-0.6.0-1" do
  command "rpm -ivh --nodeps --force http://yumrepo.digitaldreams.com/common/rubygem-mini_portile-0.6.0-1.noarch.rpm"
  not_if "/opt/chef/embedded/bin/gem list --local mini_portile|grep -q mini_portile"
  action :nothing
end.run_action(:run)
execute "digitaldreams-gem-check: aws-sdk-1.42.0-1" do
  command "rpm -ivh --nodeps --force http://yumrepo.digitaldreams.com/common/rubygem-aws-sdk-1.42.0-1.noarch.rpm"
  not_if "/opt/chef/embedded/bin/gem list --local aws-sdk|grep -q aws-sdk"
  action :nothing
end.run_action(:run)

Gem.clear_paths
require 'aws-sdk'
require 'net/http'

# Define attributes
node.default['elbname'] = "COLLABdev"

# Get AWS instance_id and define instance_id attribute
metadata_fetch_1 = 'http://169.254.169.254/latest/meta-data/'
node.default['instance_id'] = Net::HTTP.get( URI.parse( metadata_fetch_1 + 'instance-id' ) )

# Get AWS EC2 Region as aws_ec2_region
ruby_block "get_aws_region" do
  block do
    $aws_ec2_region = `curl --silent http://169.254.169.254/latest/dynamic/instance-identity/document|grep region|awk -F: '{print $2}'| sed -e 's/.*"\(.*\)"[^"]*$/\1/'`
    Chef::Log.info("AWS EC2 Region is: #{$aws_ec2_region}")
  end
end

# Created the aws-sdk data_bag on the DEVOPS Chef server
awsdata = data_bag_item("aws-sdk", "main")
awscreds = {
  :access_key_id    => awsdata['aws_access_key_id'],
  :secret_access_key => awsdata['aws_secret_access_key'],
  :region           =>  node["#{$aws_ec2_region}"]
}
AWS.config(awscreds)

# This is where we register/deregister the instance to it's ELB
# Supported actions (register/deregister).  Please be careful and
# know that if you set this to "deregister" it will remove any
# instance from it's ELB which has this recipe assigned
aws_sdk_elb node['elbname'] do
  instance_id node['instance_id'] 
  action :nothing
end
