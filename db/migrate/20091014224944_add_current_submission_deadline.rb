class AddCurrentSubmissionDeadline < ActiveRecord::Migration
  def self.up
    add_column :currents, :submission_deadline, :date
  end

  def self.down
    remove_column :currents, :submission_deadline
  end
end
