class AddVoteCountedFlag < ActiveRecord::Migration
  def self.up
    add_column :votes, :counted, :boolean, :default => false
    Vote.update_all :counted => true  # existing votes are all counted
  end

  def self.down
    remove_column :votes, :counted
  end
end
