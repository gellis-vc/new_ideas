class AddEmailPrefsToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :notify_on_comments, :boolean, :null => false, :default => false
    add_column :users, :notify_on_state, :boolean, :null => false, :default => false
  end

  def self.down
    remove_column :users, :notify_on_state
    remove_column :users, :notify_on_comments
  end
end
