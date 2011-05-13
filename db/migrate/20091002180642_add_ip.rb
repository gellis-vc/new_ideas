class AddIp < ActiveRecord::Migration
  def self.up
    add_column :comments, :ip, :string, :limit=> 16
    add_column :comments, :user_agent, :string
  end

  def self.down
    remove_column :comments, :ip
    remove_column :comments, :user_agent
  end
end
