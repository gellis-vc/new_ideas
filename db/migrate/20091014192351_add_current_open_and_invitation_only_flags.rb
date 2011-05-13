class AddCurrentOpenAndInvitationOnlyFlags < ActiveRecord::Migration
  def self.up
    add_column :currents, :closed, :boolean, :default=>false
    add_column :currents, :invitation_only, :boolean, :default=>false
  end

  def self.down
    remove_column :currents, :closed
    remove_column :currents, :invitation_only
  end
end
