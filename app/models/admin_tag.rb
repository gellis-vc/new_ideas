class AdminTag < ActiveRecord::Base
  
  has_and_belongs_to_many :ideas, :join_table => :ideas_admin_tags
  
  include TagHelper
  
end
