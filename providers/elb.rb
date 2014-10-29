def whyrun_supported?
  true
end

action :register do
  if @current_resource.exists
    Chef::Log.info "#{ @new_resource } already exists - nothing to do."
  else
    converge_by("Create #{ @new_resource }") do
      register_to_elb
    end
  end
end

action :deregister do
  deregister_from_elb
end

def load_current_resource
  @current_resource = Chef::Resource::AwsSdkElb.new(@new_resource.name)
  @current_resource.name(@new_resource.name)
  @current_resource.elbname(@new_resource.elbname)
  @current_resource.instance_id(@new_resource.instance_id)
end

def register_to_elb
  ec2 = AWS::EC2.new
  elb = AWS::ELB.new
  elbname = new_resource.elbname
  instance_id = new_resource.instance_id
  elb.load_balancers[elbname].instances.register(instance_id)
end

def deregister_from_elb
  ec2 = AWS::EC2.new
  elb = AWS::ELB.new
  elbname = new_resource.elbname
  instance_id = new_resource.instance_id
  elb.load_balancers[elbname].instances.deregister(instance_id)
end


