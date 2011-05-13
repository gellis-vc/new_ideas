class AddFacebookFields < ActiveRecord::Migration
  def self.up
    add_column :users, :fb_uid, :string
    add_column :users, :fb_email_hash, :string
  end

  def self.down
    remove_column :users, :fb_email_hash
    remove_column :users, :fb_uid
  end
end
