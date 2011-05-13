class AddStatus < ActiveRecord::Migration
  def self.up
    add_column :ideas, :status, :string, :default=>'new', :null => false, :limit=>20
  end

  def self.down
    remove_column :ideas, :status
  end
end
