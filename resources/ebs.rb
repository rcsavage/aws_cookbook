actions :attach
 
attribute :volname, :name_attribute => true, :kind_of => String, :required => true
attribute :size, :kind_of => Integer 
attribute :device, :kind_of => String
attribute :type, :kind_of => String, :default => "standard"

attr_accessor :exists
