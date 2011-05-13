class DropXap < ActiveRecord::Migration
  def self.up
    create_table(:acts_as_xapian_jobs, :force=>true){}
    drop_table :acts_as_xapian_jobs
  end

  def self.down
  end
end
