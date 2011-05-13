class FixCurrents < ActiveRecord::Migration
  def self.up
    d = Current.find_by_title('Default Current')
    Current.connection.execute("update ideas set current_id=#{d.id}")
  end

  def self.down
  end
end
