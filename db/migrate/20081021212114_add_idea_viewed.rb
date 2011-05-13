class AddIdeaViewed < ActiveRecord::Migration
  def self.up
    add_column :ideas, :viewed, :boolean, :default => false
  end

  def self.down
    remove_column :ideas, :viewed
  end
end
