class LinkDuplicateIdeas < ActiveRecord::Migration
  def self.up
    add_column :ideas, :duplicate_of_id, :integer
  end

  def self.down
    remove_column :ideas, :duplicate_of_id
  end
end
