class ConvertIdeaRatingToDecimal < ActiveRecord::Migration
  def self.up
    change_column :ideas, :rating, :decimal, :precision => 10, :scale=>2
  end

  def self.down
  end
end
