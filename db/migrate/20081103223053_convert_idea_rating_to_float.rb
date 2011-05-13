class ConvertIdeaRatingToFloat < ActiveRecord::Migration
  def self.up
    change_column :ideas, :rating, :float
  end

  def self.down
    change_column :ideas, :rating, :integer
  end
end
