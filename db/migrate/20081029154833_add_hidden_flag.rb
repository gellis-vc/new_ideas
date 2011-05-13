class AddHiddenFlag < ActiveRecord::Migration
  def self.up
    add_column :ideas,    :hidden, :boolean, :default => false
    add_column :comments, :hidden, :boolean, :default => false
  end

  def self.down
    remove_column :ideas,    :hidden
    remove_column :comments, :hidden
  end
end
