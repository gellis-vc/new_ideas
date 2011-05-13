class LifeCycle < ActiveRecord::Base
  
  acts_as_authorizable
  
  has_many :steps, :class_name => 'LifeCycleStep', :order => 'position', :dependent => :destroy
  
  validates_presence_of :name
  
end
