
scenario :basic do
  
  # ------ Postal Codes ------
  
  conn = ActiveRecord::Base.connection
  conn.execute "insert into postal_codes (code, lat, lon) values ('55101', 33.1, -80.5)"
  conn.execute "insert into postal_codes (code, lat, lon) values ('55102', 36.5, -91.7)"
  conn.execute "insert into postal_codes (code, lat, lon) values ('55103', 49.8, -102.3)"
  conn.execute "insert into postal_codes (code, lat, lon) values ('55406', 49.8, -102.3)"
  
  # ------ Users ------
  
  @quentin = User.create!(
    :name => "Quentin X. Test",
    :email => "quentin@example.com",
    :zip_code => '55101',
    :password => "test",
    :contribution_points => 5,
    :password_confirmation => "test",
    :terms_of_service => '1')
  @quentin.activate!
  
  @aaron = User.new(
    :name => "Aaron Zzyzzygy",
    :email => "aaron@example.com",
    :zip_code => '55102-2753',
    :password => "test",
    :password_confirmation => "test",
    :terms_of_service => '1')
  @aaron.register!
  
  @sally = User.create!(
    :name => "Sally O'Test",
    :email => "sally@example.com",
    :zip_code => '57 Q Z 3123',
    :password => "test",
    :password_confirmation => "test",
    :contribution_points => 4,
    :terms_of_service => '1')
  @sally.activate!

  @participator = User.create!(
    :name => "Participant In Currents",
    :email => "particpator@example.com",
    :zip_code => '55102-2753',
    :password => "test",
    :contribution_points => 3,
    :password_confirmation => "test",
    :terms_of_service => '1')
  @participator.activate!
  
  @tweeter = User.create!(
    :name => "Tweeter O'Test",
    :email => "tweeter@example.com",
    :zip_code => '57 Q Z 3123',
    :password => "test",
    :tweet_ideas => true,
    :contribution_points => 3,
    :password_confirmation => "test",
    :terms_of_service => '1')
  @tweeter.activate!
  
  @currents_admin = User.create!(
    :name => "Currents Admin",
    :email => "currentadmin@example.com",
    :zip_code => '55108-2753',
    :password => "test",
    :contribution_points => 3,
    :password_confirmation => "test",
    :terms_of_service => '1')
  @currents_admin.has_role 'admin', Current
  
  @admin_user = User.create!(
    :name => "Admin User",
    :email => "admin@example.com",
    :zip_code => '55103',
    :password => "admin",
    :password_confirmation => "admin",
    :terms_of_service => '1')
  @admin_user.activate!
  @admin_user.has_role 'admin'
  @admin_user.has_role 'editor', User
  @admin_user.has_role 'editor', Idea
  @admin_user.has_role 'editor', LifeCycle
  
  # ------ Currents ------
  
  @default_current = Current.create!(
      :title => 'Placeholder for default current',
      :description => 'This is a stand-in for the default current created by the add_idea_current_relationship migration.')
  #@default_current.id = Current::DEFAULT_CURRENT_ID
  #@default_current.save!
  puts "Setting Current::DEFAULT_CURRENT_ID to match the id of @default_current fixture.  Ignore the complaint."
  Current::DEFAULT_CURRENT_ID = @default_current.id
  
  @walrus_attack_current = @admin_user.currents.create!(
    :title => 'Dealing with walruses',
    :description => 'Friends, Blueshirts and Customers, I beseech you to recommend ways to deal with walrus attacks.',
    :submission_deadline => Date.today + 1)
  
  @orphan_current =   Current.create!(
      :title => 'Help me Figure out who I am',
      :description => 'I want to solicit ideas, but I dont know who I am.')
      
  @closed_current =   Current.create!(
      :title => 'Help me Figure out who I am',
      :description => 'I want to solicit ideas, but I dont know who I am.',
      :closed => true)
  
  # Intentionally left closed false while submission_deadline has passed
  @expired_current =  Current.create!(
      :title => 'Submit your comments by the end of the day yesterday.',
      :description => 'I have to solicit ideas, but I dont ever look at a calendar and dont plan to actually read your ideas.',
      :closed => false,
      :submission_deadline => Date.today - 1)
  
  @private_current =   Current.create!(
      :title => 'Help me Figure out who I am',
      :description => 'I want to solicit ideas, but I dont know who I am.',
      :invitation_only => true) 
  @participator.has_role 'invitee', @private_current
           
  # ------ Ideas ------
  
  @walruses_in_stores = @quentin.ideas.create!(
    :status=>'new',
    :title => 'Release walruses in stores',
    :description => 'Allow walruses to roam free in Best Buy stores and play the video game demos!',
    :created_at => Time.utc(2008, 1, 1))
  
  @barbershop_discount = @sally.ideas.create!(
    :status=>'new',
    :title => 'Discounts for barbershop quartets',
    :description => 'It is the moral duty of Best Buy to maximize singing by giving any barbershop quartet member a 50% in-store discount.',
    :created_at => Time.utc(2008, 1, 2))
  
  @hidden_idea = @sally.ideas.create!(
    :status=>'new',
    :title => 'Rowerbazzle!',
    :description => 'Garflatzin gronglebunkcles!!',
    :created_at => Time.utc(2008, 1, 2),
    :current => @walrus_attack_current,
    :hidden => true)
  
  @spam_idea = @quentin.ideas.create!(
    :status=>'new',
    :title => 'Get much skeezier!',
    :description => 'This pill will maximize your skeeziness! Get much more!',
    :created_at => Time.utc(2008, 1, 2),
    :marked_spam => true)
  
  @tranquilizer_guns = @participator.ideas.create!(
      :title => 'Provide all blueshirts with tranquilizer guns',
      :description => 'Best Buy Militia!',
      :current => @walrus_attack_current)

  @give_up_all_hope = @participator.ideas.create!(
    :title => 'Give up all hope',
    :description => 'You will never defeat the walruses.',
    :current => @walrus_attack_current)
      
  # Don't assign this to a current!
  @orphan_idea = Idea.create!(
    :title => 'Sell rocket parts', 
    :description => 'Submitted without login')
  
  @aaron.save! 
      
  @inactive_user_idea = @aaron.ideas.create!(:title => 'Butter both sides of bread', :description => 'Decadent!', :status=>'new', :current => @default_current)
  
  @duplicate_idea = @sally.ideas.create!(:title => 'Tusky mammals', :description => 'Put them in retail establishments!', :duplicate_of => @walruses_in_stores, :current => @default_current)

  # ------ Comments ------
  
  @walrus_comment1 = @walruses_in_stores.comments.create!(
    :author => @aaron,
    :ip => '127.0.0.1',
    :user_agent=>'Macosx safari or whatever',
    :text => "It's so crazy it just might work!")
  
  @walrus_comment2 = @walruses_in_stores.comments.create!(
    :author => @sally,
    :ip => '127.0.0.1',
    :user_agent=>'Macosx safari or whatever',
    :text => "Here's to walruses.")
  
  @walrus_comment_spam = @walruses_in_stores.comments.create!(
    :author => @sally,
    :ip => '127.0.0.1',
    :user_agent=>'Macosx safari or whatever',
    :marked_spam=>true,
    :text =><<-EOS
      <!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
      <HTML><HEAD><TITLE></TITLE>
      </HEAD>
      <BODY>

      <html>
      <body bgcolor="#FFFFFF">
      The best way to save on your me<span style="FONT-SIZE: 2px; FLOAT: right; COLOR: white"> nx </span>dica<span style="FONT-SIZE: 2px; FLOAT: right; COLOR: white"> qw </span>tions is to order them in Canada, as they are cheaper there. You don't have to worry about the quality, purchase with «Can<span style="FONT-SIZE: 2px; FLOAT: right; COLOR: white"> zo </span>adia<span style="FONT-SIZE: 2px; FLOAT: right; COLOR: white"> rxf </span>nPha<span style="FONT-SIZE: 2px; FLOAT: right; COLOR: white"> cb </span>rmacy» online dru<span style="FONT-SIZE: 2px; FLOAT: right; COLOR: white"> yqa </span>gstore and you'll receive world class quality me<span style="FONT-SIZE: 2px; FLOAT: right; COLOR: white"> fok </span>ds!<br><br>
      <i>Purchase me<span style="FONT-SIZE: 2px; FLOAT: right; COLOR: white"> que </span>dications with «Can<span style="FONT-SIZE: 2px; FLOAT: right; COLOR: white"> xdh </span>adia<span style="FONT-SIZE: 2px; FLOAT: right; COLOR: white"> jde </span>nPha<span style="FONT-SIZE: 2px; FLOAT: right; COLOR: white"> xzr </span>rmacy» and you will make significant savings.<br>Absolutely high quality me<span style="FONT-SIZE: 2px; FLOAT: right; COLOR: white"> ae </span>dications at cheap prices are available 7 days a week 24 hours a day.<br>You can make your order confidentially and at the time that suits you.<br>Our order will be delivered in short term and without any delays.</i><br><br>
      <u>Dont hesitate to purchase with «Can<span style="FONT-SIZE: 2px; FLOAT: right; COLOR: white"> puu </span>adia<span style="FONT-SIZE: 2px; FLOAT: right; COLOR: white"> up </span>nPha<span style="FONT-SIZE: 2px; FLOAT: right; COLOR: white"> ebq </span>rmacy»!</u><br><br>
      <font color="#FFB6C1" size="2">-----------------------------------------------------</font><br>
      <b>More information here  --- >   www.modelfizz.com</b><br>
      <font color="#FFB6C1" size="2">-----------------------------------------------------</font>
      </body>
      </html>

      </BODY></HTML>
    EOS
  )
    
  @hidden_comment = @walruses_in_stores.comments.create!(
    :author => @sally,
    :ip => '127.0.0.1',
    :user_agent=>'Macosx safari or whatever',
    :text => "grabblefratzin' walruses!!",
    :hidden => true)
  
  @comment_on_hidden_idea = @hidden_idea.comments.create!(
    :author => @sally,
    :ip => '127.0.0.1',
    :user_agent=>'Macosx safari or whatever',
    :text => "Wow, somebody should hide this idea! Think of the children!")
    
  # ------ Tags ------
  
  @walrus_tag = Tag.create!(:name => 'walrussy')
  @crazy_tag = Tag.create!(:name => 'crazy ideas')
  @walruses_in_stores.tags << @walrus_tag
  @walruses_in_stores.tags << @crazy_tag
  @barbershop_discount.tags << @crazy_tag
  
  @hire_this_person_tag = AdminTag.create!(:name => 'hire this person')
  @barbershop_discount.admin_tags << @hire_this_person_tag
  
  @walruses_in_stores.save!
  @barbershop_discount.save!
  
  # ------ Life cycles ------
  
  @good_idea = LifeCycle.create!(:name => 'Good idea')
  @good_idea_review    = @good_idea.steps.create!(:name => 'Legal review')
  @good_idea_implement = @good_idea.steps.create!(:name => 'Implement everywhere')
  @good_idea_dance     = @good_idea.steps.create!(:name => 'Do a happy dance')
  @good_idea_done      = @good_idea.steps.create!(:name => 'Done')
  
  @bad_idea = LifeCycle.create!(:name => 'Bad idea')
  @bad_idea_mock      = @bad_idea.steps.create!(:name => 'Mock customer')
  @bad_idea_done      = @bad_idea.steps.create!(:name => 'Done')
  
  @walruses_in_stores.life_cycle_step = @good_idea_dance
  @walruses_in_stores.save!
  
  @admin_user.life_cycle_steps = [@good_idea_dance, @bad_idea_mock]
  @admin_user.save!
  
  # ------ OAuth ------
  
  @phone_app = @admin_user.client_applications.build(
    :name => 'Phone app',
    :url => 'http://foo',
    :callback_url => 'http://foo/callback')
  @phone_app.save!
  
  # ------ Final prep ------
  
  @sally.contribution_points = 100
  @quentin.contribution_points = 200
  @sally.save!
  @quentin.save!
  
  # WARNING: only one scenario can be indexed by Xapian!
  #ActsAsXapian.rebuild_index([Idea], false)
  
  names_from_ivars!
end

scenario :xss_attack do
  def attack(field)
    "<attack>#{field}<attack>"
  end
  
  conn = ActiveRecord::Base.connection
  conn.execute 'insert into postal_codes (code, lat, lon) values (\'12345\', 40, -100)'
  
  @user = User.create!(
    :name => attack('user.name'),
    :email => 'user@example.com',
    :zip_code => '12345' + attack('user.zip_code'),
    :password => attack('user.password'),
    :password_confirmation => attack('user.password'),
    :terms_of_service => '1')
  @user.activate!
  @user.moderator = true
  @user.reset_activation_code
  @user.notify_on_comments = true
  @user.notify_on_state = true
  @user.save!
  @user.has_role 'admin'
  @user.has_role 'editor', User
  @user.has_role 'editor', Idea
  @user.has_role 'editor', LifeCycle
  @user.has_role 'editor', ClientApplication
  @user.has_role 'editor', Current
  
  @user2 = User.create!(
    :name => attack('user2.name'),
    :email => 'user2@example.com',
    :zip_code => '12345' + attack('user2.zip_code'),
    :password => attack('user2.password'),
    :password_confirmation => attack('user2.password'),
    :terms_of_service => '1')
  @user2.activate!
  @user2.reset_activation_code
  @user2.save!
  
  @pending_user = User.new(
    :name => attack('pending_user.name'),
    :email => 'pending@example.com',
    :zip_code => attack('pending_user.zip_code'),
    :password => attack('pending_user.password'),
    :terms_of_service=>'1',
    :password_confirmation => attack('pending_user.password'))
  @pending_user.register!
  @pending_user.save!
  
  # ------ Currents ------
  @default_current = Current.create!(
      :title => 'Placeholder for default current',
      :description => 'This is a stand-in for the default current created by the add_idea_current_relationship migration.')
  
  # ------ Ideas ------
  @idea = @user.ideas.create!(
    :status=>'new',
    :title => attack('idea.title'),
    :description => attack('idea.description'),
    :inappropriate_flags => 1)
    
  @idea2 = @user2.ideas.create!(
    :status=>'new',
    :title => attack('idea2.title'),
    :description => attack('idea2.description'),
    :inappropriate_flags => 1)
    
  @comment = @idea.comments.create!(
    :author => @user,
    :text => attack('comment.text'),
    :ip=> '127.0.0.1',
    :user_agent=>'Macosx safari or whatever',
    :inappropriate_flags => 1)
    
  @admin_comment = @idea.admin_comments.create!(
    :author => @user,
    :text => attack('admin_comment.text'))
    
  @tag = @idea.tags.create!(:name => attack('tag.name'))
  @admin_user_tag = @idea.admin_tags.create!(:name => attack('admin_tag.name'))
  
  @life_cycle = LifeCycle.create!(:name => attack('life_cycle.name'))
  @life_cycle_step = @life_cycle.steps.create!(:name => attack('life_cycle_step.name'), :admins => [@user])
  
  # ------ Currents ------
  
  @current = @user.currents.create!(
    :title => attack('current.title'),
    :description => attack('current.description'))
  @current.ideas << @idea
  
  # ------ Client Apps ------
  
  @client_app = @user.client_applications.build(
    :name         => attack('client_application.name'),
    :url          => 'http://' + attack('client_application.url'),
    :callback_url => 'http://' + attack('client_application.callback_url'))
  @client_app.save!
  
  names_from_ivars!
end
