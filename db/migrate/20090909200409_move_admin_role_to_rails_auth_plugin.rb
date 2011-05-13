class MoveAdminRoleToRailsAuthPlugin < ActiveRecord::Migration
  def self.up
    User.find(:all, :conditions => { :admin => true }).each do |user|
      puts "Granting admin privileges to user #{user.id}"
      user.has_role 'admin'
      user.has_role 'modify', User
      user.has_role 'modify', Idea
      user.has_role 'modify', Comment
    end
    remove_column :users, :admin
  end

  def self.down
    add_column :users, :admin, :boolean, :default => false
    admin_role = Role.find(:first, :conditions => { :name => 'admin', :authorizable_type => nil })
    if admin_role
      admin_role.users.each do |user|
        user.admin = true
        user.save!
      end
    end
  end
end
