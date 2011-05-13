class AddInappropriateFlag < ActiveRecord::Migration
  def self.up
    add_column :ideas,    :inappropriate_flags, :integer, :default => 0
    add_column :comments, :inappropriate_flags, :integer, :default => 0
  end

  def self.down
    remove_column :ideas,    :inappropriate_flags
    remove_column :comments, :inappropriate_flags
  end
end
