class Anyelement < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base.connection.execute <<-EOF
    CREATE AGGREGATE array_agg (anyelement)
    (
         sfunc = array_append,
            stype = anyarray,
               initcond = '{}'
    );
    
    EOF
  end

  def self.down
  end
end
