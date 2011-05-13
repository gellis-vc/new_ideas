class AddIdeaFlag < ActiveRecord::Migration
  def self.up
    add_column :ideas, :flagged, :boolean
  end

  def self.down
    remove_column :ideas, :flagged
  end
end
