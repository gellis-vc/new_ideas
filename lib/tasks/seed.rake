require 'fastercsv'

namespace :db do
  task :default_current => [:environment] do 
    if Current.count < 1
      puts "creating new default current, adding all ideas to it."
      c = Current.create(:title => 'Default Current', :description => 'Default current', :inventor=> User.find_by_email('admin@example.com'))
      ActiveRecord::Base.connection.execute("update ideas set current_id=#{c.id}")
    else
      puts "you already have defined a current, presumably you know what you're doing."
    end
  end
  desc "Load seed data into the current environment's database."
  task :seed => [ :environment, :'db:migrate' ] do
    PostalCode.transaction do
      
      # This reassigns IDs; find an alternative!
      # PostalCode.connection.execute("truncate postal_codes")
      if PostalCode.count > 0
        puts "Database already contains #{PostalCode.count} postal codes. Skipping postal code loading. " +
             "Update the seed script to somehow preserve the id column if you want to update the postal codes.\n"
      else
        puts "Loading postal codes..."
        s = "insert into postal_codes (code, lat, lon) values "
        pc = []
        fname = File.join(File.dirname(__FILE__), "../../db/data/zips.csv.gz")
        raise "can't find zips.csv: #{fname}" unless File.exists? fname
        handle = Zlib::GzipReader.new(File.open(fname))
        FasterCSV.new(handle).each do |r|
          r= r.map{|x| x.gsub(/'/,'')}
          pc << PostalCode.send(:sanitize_sql_array, (["(?, ?, ?)", r[0], r[2].to_f, r[3].to_f]))
        end

        ActiveRecord::Base.connection.execute(s<<pc.join(","))
      end
      
      @admin_user = User.find_by_email("admin@example.com") 
      if @admin_user
        puts "Admin user already exists."
      else
        puts "Creating admin user..."
        @admin_user = User.create!(
          :name => "Administrator",
          :email => "admin@example.com",
          :zip_code => '55423',
          :password => "z357pt3k58c7",
          :password_confirmation => "z357pt3k58c7",
          :terms_of_service => '1')
      end
      puts "Granting admin privileges to #{@admin_user.email}..."
      @admin_user.activate!
      @admin_user.has_role 'admin'
      @admin_user.has_role 'editor', User
      @admin_user.has_role 'editor', Idea
      @admin_user.has_role 'editor', Comment
      @admin_user.has_role 'editor', Current
      @admin_user.has_role 'editor', LifeCycle
      @admin_user.has_role 'editor', ClientApplication
      @admin_user.save!
      
      puts "Seed complete."
    end
  end
end
