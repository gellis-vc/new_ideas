class AddTwitterFields < ActiveRecord::Migration
  def self.up
    add_column :users, :twitter_handle, :string
    add_column :users, :tweet_ideas, :boolean
  end

  def self.down
    remove_column :users, :tweet_ideas
    remove_column :users, :twitter_handle
  end
end
