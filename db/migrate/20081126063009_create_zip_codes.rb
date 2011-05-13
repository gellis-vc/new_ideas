class CreateZipCodes < ActiveRecord::Migration
  def self.up
    create_table :postal_codes, :force => true do |t|
      t.string :code
      t.float :lat
      t.float :lon
    end
    add_index :postal_codes, :code
    add_column :users, :postal_code_id, :integer
  end

  def self.down
    remove_column :users, :postal_code_id
    drop_table :postal_codes
  end
end
