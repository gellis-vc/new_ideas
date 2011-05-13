class MarkedSpam < ActiveRecord::Migration
  def self.up
    rename_column :ideas, :spam, :marked_spam
    add_column :comments, :marked_spam, :boolean, :default=>false
  end

  def self.down
    remove_column :comments, :marked_spam
    rename_column :ideas, :marked_spam, :spam
  end
end
