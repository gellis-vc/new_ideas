class CreateAdminComments < ActiveRecord::Migration
  def self.up
    create_table :admin_comments do |t|
      t.integer :idea_id
      t.integer :author_id
      t.text :text

      t.timestamps
    end
  end

  def self.down
    drop_table :admin_comments
  end
end
