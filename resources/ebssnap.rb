actions :enable
 
attribute :tagname, :name_attribute => true, :kind_of => String, :required => true
attribute :retention, :kind_of => Integer 
attribute :frequency, :kind_of => String

attr_accessor :exists
