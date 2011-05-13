namespace :db do
  desc "Wipe database and load bulk data for load testing, etc."
  task :bulkload=>:environment do
    require 'ruby-debug'
    lorem = <<-EOF
    orem ipsum dolor sit amet, consectetuer adipiscing elit. Curabitur vulputate. Ut at nunc. Morbi lacinia. Phasellus est. Praesent arcu tortor, malesuada ac, pharetra quis, fringilla quis, massa. Etiam tincidunt elementum enim. Donec pellentesque pharetra lacus. Phasellus sapien. Vivamus porttitor felis molestie massa. Sed rhoncus fermentum felis.
    EOF

    words = File.read("/usr/share/dict/words").split.select{|x|x.size > 5}
    names = File.read("/usr/share/dict/words").split
    c= words.size
    z= names.size
    puts "read #{c} words, #{z} proper  names"
    Vote.destroy_all
    Tag.destroy_all
    Comment.destroy_all
    Idea.destroy_all
    User.destroy_all
    a = User.new(:name=>'Admin User', :admin=>1, :password=>'standard', :password_confirmation=>'standard', :terms_of_service=>1, :email=>'admin@example.com', :zip_code=>55407)
    a.register!
    a.activate!
    ActiveRecord::Base.silence do 
      ActiveRecord::Base.transaction do
          s = Time.now
        5000.times do |n|
          first=names[rand(z)]
          last = names[rand(z)]
          u = User.create(
            :name=>"#{first} #{last}",
            :email => "#{first}#{last}@example.com",
            :activated_at=>Time.now,
            :dstate=>'active',
            :zip_code=>rand(55407),
            :password=>'standard',
            :password_confirmation=>'standard',
            :terms_of_service=>1
          )
          begin
            u.register!
            u.activate!
          rescue
            p "failed to save user due to #{u.errors.each_full{}}"
            next
          end

          i = u.ideas.create!(:title=>words[rand(n)],
                              :description=>lorem,
                              :rating => rand(10.0)
                             )
                             i.save!

                             if n%100 == 0
                               d = Time.now - s
                              p "#{n}...#{d}/100"
                              s = Time.now
                             end
        end
        p "tagging..."
        ideas = Idea.find(:all)
        ideas.each {|x| 
          begin
          rand(10).times {x.admin_tags.create(:name=>words[rand(words.size)])}
          rand(10).times {x.tags.create(:name=>words[rand(words.size)])}
          rescue
            next
          end
        }
        user_ids = User.find(:all, :select=>'id').map{|x|x.id}
        idea_ids = Idea.find(:all, :select=>'id').map{|x|x.id}
        uc = user_ids.size
        ic = idea_ids.size
        p "creating comments"
        user_ids.each{|x| rand(20).times{Comment.create!(:author_id=>x, :text=>lorem, :idea_id=>idea_ids[rand(ic)] )}}

        p "voting.."
        user_ids.each {|x|(50).times {Vote.create(:idea_id=>idea_ids[rand(ic)], :user_id=>x)}}
      end
    end
    puts "Created #{Comment.count} comments, #{Idea.count} ideas, #{User.count} users, #{AdminTag.count} admin tags, #{Tag.count} tags, #{Vote.count} votes."

  end
end
