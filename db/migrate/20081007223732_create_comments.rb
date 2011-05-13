class CreateComments < ActiveRecord::Migration
  def self.up
    create_table :comments, :force => true do |t|
      t.integer :idea_id
      t.integer :author_id
      t.string  :text
      t.timestamps
    end
  end

  def self.down
    drop_table :comments
  end
end
