def whyrun_supported?
  true
end

action :attach do
  if @current_resource.exists
    Chef::Log.info "#{ @new_resource } already exists - nothing to do."
  else
    converge_by("Create #{ @new_resource }") do
      device_attach 
    end
  end
end

def load_current_resource
  @current_resource = Chef::Resource::AwsSdkEbs.new(@new_resource.name)
  @current_resource.name(@new_resource.name)
  @current_resource.volname(@new_resource.volname)
  @current_resource.size(@new_resource.size)
  @current_resource.device(@new_resource.device)
  @current_resource.type(@new_resource.type)
end

def device_attach
  ec2 = AWS::EC2.new
  volname = new_resource.volname
  size = new_resource.size
  device = new_resource.device
  type = new_resource.type

  return if (node['awssdk'] && node['awssdk']['volumes'] && node['awssdk']['volumes']["#{device}"] rescue false)
  provision_new_storage = 'true'

  if provision_new_storage == 'true'

    # Get AWS instance_id and define instance_id attribute
    metadata_fetch_1 = 'http://169.254.169.254/latest/meta-data/'
    node.default['instance_id'] = Net::HTTP.get( URI.parse( metadata_fetch_1 + 'instance-id' ) )

    metadata_fetch_2 = 'http://169.254.169.254/latest/meta-data/placement/'
    node.default['ec2_av_zone'] = Net::HTTP.get( URI.parse( metadata_fetch_2 + 'availability-zone') )

    volumes = ec2.volumes.each_with_object({}) do |v, m|
      m[v.id] = {status: v.status, name: v.tags["Name"], instance: v.tags["Instance"]}
    end

    if "#{provision_new_storage}" == "true"
      log "Provisioning new storage..."
      # Create an empty volume and attach it to an instance
      volume = ec2.volumes.create(:size => new_resource.size, :volume_type => "#{type}",
                              :availability_zone => "#{node[:ec2_av_zone]}")
      vol_id = volume.id
      ec2.volumes["#{vol_id}"].tags["Name"] = new_resource.volname
      ec2.volumes["#{vol_id}"].tags["Instance"] = "#{node[:instance_id]}"
      ec2.volumes["#{vol_id}"].tags["Volume_id"] = "#{vol_id}"
      ec2.volumes["#{vol_id}"].tags["Device"] = "#{device}"
      node.normal['awssdk']['volumes']["#{device}"]['volume_id'] = "#{vol_id}"
      node.save unless Chef::Config[:solo]
      sleep 1 until volume.status == :available

      log "EBS Volume: #{vol_id}"
      log "EC2 Instnace: #{node[:instance_id]}"

      unless "#{vol_id}".nil? || "#{vol_id}".empty?
        # Attach volume to instance if newly created or detatched
        attachment = volume.attach_to(ec2.instances["#{node[:instance_id]}"], new_resource.device)
        sleep 1 until attachment.status != :attaching
      end
    end
  end
end
