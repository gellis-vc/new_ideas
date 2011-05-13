class LifeCycleStep < ActiveRecord::Base
  
  belongs_to :life_cycle
  acts_as_list :scope => :life_cycle
  
  validates_presence_of :name, :life_cycle
  
  has_and_belongs_to_many :admins, :class_name => 'User', :join_table => 'life_cycle_steps_admins'
  
  # True if this step comes next after the given step in the same life cycle.
  def follows?(other_step)
    life_cycle_id == other_step.life_cycle_id && position == other_step.position + 1
  end
  
end
