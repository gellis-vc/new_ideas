class CreateAdminTags < ActiveRecord::Migration
  def self.up
    create_table :admin_tags, :force => true do |t|
      t.string :name
      t.timestamps
    end
    
    create_table :ideas_admin_tags, :id => false do |t|
      t.integer :idea_id
      t.integer :admin_tag_id
    end
  end

  def self.down
    drop_table :ideas_admin_tags
    drop_table :admin_tags
  end
end
