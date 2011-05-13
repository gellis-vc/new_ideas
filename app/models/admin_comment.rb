class AdminComment < ActiveRecord::Base
  
  belongs_to :idea
  belongs_to :author, :class_name => 'User'
  
  validates_presence_of :idea, :author, :text
  
end
