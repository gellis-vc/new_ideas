class ConvertIdeaAndCommentFieldsToText < ActiveRecord::Migration
  def self.up
    change_column :ideas, :title, :text
    change_column :ideas, :description, :text
    change_column :comments, :text, :text
  end

  def self.down
    change_column :ideas, :title, :string
    change_column :ideas, :description, :string
    change_column :comments, :text, :string
  end
end
