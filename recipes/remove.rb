#
# Cookbook Name:: aws_sdk
# Recipe:: remove 
#
# Copyright 2014, digitaldreams 
# All rights reserved - Do Not Redistribute

# Remove required packages for use with aws_sdk
# This is the RPM Check Section
%w{rubygem-nokogiri rubygem-mini_portile rubygem-aws-sdk}.each do |pkg|
  package pkg do
    action :remove
  end
end

