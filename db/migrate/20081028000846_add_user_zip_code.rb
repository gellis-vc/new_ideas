class AddUserZipCode < ActiveRecord::Migration
  def self.up
    add_column :users, :zip_code, :string
    User.find(:all).each do |user|
      user.zip_code = '00000'
      user.save!
    end
  end

  def self.down
    remove_column :users, :zip_code
  end
end
