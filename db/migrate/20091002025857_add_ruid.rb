class AddRuid < ActiveRecord::Migration
  def self.up
    add_column :roles_users, :id, :integer, :primary_key=>true
  end

  def self.down
  end
end
