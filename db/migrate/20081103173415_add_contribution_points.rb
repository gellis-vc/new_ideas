class AddContributionPoints < ActiveRecord::Migration
  def self.up
    add_column :users, :contribution_points, :float, :default => 0
    add_column :users, :decayed_at, :timestamp
    add_column :ideas, :decayed_at, :timestamp
  end

  def self.down
    remove_column :ideas, :decayed_at
    remove_column :users, :decayed_at
    remove_column :users, :contribution_points
  end
end
