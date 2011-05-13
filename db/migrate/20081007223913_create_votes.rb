class CreateVotes < ActiveRecord::Migration
  def self.up
    create_table :votes, :force => true do |t|
      t.integer :idea_id
      t.integer :user_id
    end
  end

  def self.down
    drop_table :votes
  end
end
