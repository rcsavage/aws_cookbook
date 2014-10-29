#
# Cookbook Name:: aws_sdk
# Recipe:: modules 
#
# Copyright 2014, digitaldreams 
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

# We have to run clear_paths to tell Chef to re-examine the gem library
Gem.clear_paths
