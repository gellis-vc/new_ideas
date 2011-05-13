class CreateCurrents < ActiveRecord::Migration
  def self.up
    create_table :currents, :force=>true do |t|
      t.string :title
      t.text :description
      t.integer :inventor_id
      t.timestamps
    end
  end

  def self.down
    drop_table :currents
  end
end
