class AddIdeaSpamFlag < ActiveRecord::Migration
  def self.up
    add_column :ideas,    :spam, :boolean, :default => false
  end

  def self.down
    remove_column :ideas,    :spam
  end
end
