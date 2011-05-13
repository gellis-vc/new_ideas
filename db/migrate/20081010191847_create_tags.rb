class CreateTags < ActiveRecord::Migration
  def self.up
    create_table :tags, :force => true do |t|
      t.column :name, :string
    end
    
    create_table :ideas_tags, :force => true, :id => false do |t|
      t.integer :idea_id
      t.integer :tag_id
    end
  end

  def self.down
    drop_table :ideas_tags
    drop_table :tags
  end
end
