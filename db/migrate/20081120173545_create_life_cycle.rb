class CreateLifeCycle < ActiveRecord::Migration
  def self.up
    create_table :life_cycles, :force => true do |t|
      t.string :name
      t.timestamps
    end
    
    create_table :life_cycle_steps, :force => true do |t|
      t.integer :life_cycle_id
      t.integer :position
      t.string :name
      t.timestamps
    end
    
    add_column :ideas, :life_cycle_step_id, :integer
  end

  def self.down
    remove_column :ideas, :life_cycle_step_id
    drop_table :life_cycle_steps
    drop_table :life_cycles
  end
end
