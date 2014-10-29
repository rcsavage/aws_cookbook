def whyrun_supported?
  true
end

use_inline_resources if defined?(use_inline_resources)

action :enable do
  awsdata = data_bag_item("aws-sdk", "main")
  template "/etc/cron.#{@new_resource.frequency}/ebssnap.rb" do
    cookbook "aws_sdk"
    source "ebssnap.erb"
    owner  "root"
    group  "root"
    mode   "0744"
     variables(:retention => new_resource.retention,
               :tagname => new_resource.tagname,
               :frequency => new_resource.frequency,
               :access_key_id => awsdata['aws_access_key_id'],
               :secret_access_key => awsdata['aws_secret_access_key']
     )
  end
  if @current_resource.exists
    Chef::Log.info "#{@new_resource} already exists - nothing to do."
  else
    converge_by("Create #{@new_resource}") do
      volume_snapshot 
    end
  end
end

def load_current_resource
  @current_resource = Chef::Resource::AwsSdkEbssnap.new(@new_resource.name)
  @current_resource.name(@new_resource.name)
  @current_resource.tagname(@new_resource.tagname)
  @current_resource.retention(@new_resource.retention)
  @current_resource.frequency(@new_resource.frequency)
end

def volume_snapshot 
  ec2 = AWS::EC2.new
  frequency = new_resource.frequency
  retention = new_resource.retention

  puts "Ebssnap Data..."
  puts "Frequency: #{frequency}"
  puts "Retention: #{retention}"

end
