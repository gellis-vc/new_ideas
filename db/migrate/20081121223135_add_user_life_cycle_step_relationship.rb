class AddUserLifeCycleStepRelationship < ActiveRecord::Migration
  def self.up
    create_table :life_cycle_steps_admins, :id => false, :force => true do |t|
      t.integer :user_id, :nil => false
      t.integer :life_cycle_step_id
    end
    add_column :users, :moderator, :boolean
  end

  def self.down
    remove_column :users, :moderator
    drop_table :life_cycle_steps_admins
  end
end
