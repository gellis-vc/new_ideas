class RenameModifyRoleToEditor < ActiveRecord::Migration
  def self.rename_roles(old_name, new_name)
    Role.find(:all, :conditions => { :name => old_name }).each do |role|
      puts "Renaming role #{role.id}"
      role.name = new_name
      role.save!
    end
  end
  
  def self.up
    rename_roles 'modify', 'editor'
  end

  def self.down
    rename_roles 'editor', 'modify'
  end
end
