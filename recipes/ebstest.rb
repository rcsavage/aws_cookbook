#
## Cookbook Name:: aws_sdk
## Recipe:: ebs
##
## Copyright 2014, digitaldreams 
##
## All rights reserved - Do Not Redistribute
 
require 'aws-sdk'
require 'net/http'

# Get AWS instance_id and define instance_id attribute
metadata_fetch_1 = 'http://169.254.169.254/latest/meta-data/'
node.default['instance_id'] = Net::HTTP.get( URI.parse( metadata_fetch_1 + 'instance-id' ) )

metadata_fetch_2 = 'http://169.254.169.254/latest/meta-data/placement/'
node.default['ec2_av_zone'] = Net::HTTP.get( URI.parse( metadata_fetch_2 + 'availability-zone') )

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
ec2 = AWS::EC2.new

# Options that will go into the LWRP
os_device = '/dev/sdz'
vol_name = 'vol_rsavage3'

########################################################################
volumes = ec2.volumes.each_with_object({}) do |v, m|
  m[v.id] = {status: v.status, name: v.tags["Name"], instance: v.tags["Instance"]}
end

provision_new_storage = 'true'
volumes.each do |test, info|
  # Is the volume label set, attached to the instance, and in_use?
  if "#{info[:name]}" == "#{vol_name}" and "#{info[:instance]}" == "#{node[:instance_id]}" and "#{info[:status]}" == "in_use"
    log "Volume: #{info[:name]} is attached to instance: #{node[:instance_id]} and in_use."
    provision_new_storage = 'false'
  end
end
if "#{provision_new_storage}" == "false"
  log "No new storage to provision"
end
########################################################################
if "#{provision_new_storage}" == "true"
  log "Provisioning new storage..."
  # Create an empty volume and attach it to an instance
  volume = ec2.volumes.create(:size => 400,
                              :availability_zone => "#{node[:ec2_av_zone]}")
  vol_id = volume.id
  ec2.volumes["#{vol_id}"].tags["Name"] = "#{vol_name}"
  ec2.volumes["#{vol_id}"].tags["Instance"] = "#{node[:instance_id]}"
  sleep 1 until volume.status == :available

  log "EBS Volume: #{vol_id}"
  log "EC2 Instnace: #{node[:instance_id]}"

  unless "#{vol_id}".nil? || "#{vol_id}".empty?
    # Attach volume to instance if newly created or detatched
    attachment = volume.attach_to(ec2.instances["#{node[:instance_id]}"], "#{os_device}")
    sleep 1 until attachment.status != :attaching
  end
end














