actions :register, :deregister
 
attribute :elbname, :name_attribute => true, :kind_of => String, :required => true
attribute :instance_id, :kind_of => String

attr_accessor :exists
