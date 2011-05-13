class AddIdeaCurrentRelationship < ActiveRecord::Migration
  def self.up
    default_current = Current.create!(:id=>Current::DEFAULT_CURRENT_ID, :title=>"Default Current", :description=>"This is the default current") 
    add_column :ideas, :current_id, :integer, :default=>Current::DEFAULT_CURRENT_ID
  end

  def self.down
    remove_column :ideas, :current_id
  end
end
