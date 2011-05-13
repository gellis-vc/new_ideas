class CreateIdeas < ActiveRecord::Migration
  def self.up
    create_table :ideas, :force => true do |t|
      t.string  :title
      t.string  :description
      t.integer :rating,      :default => 0
      t.integer :inventor_id
      t.timestamps
    end
  end

  def self.down
    drop_table :ideas
  end
end
