require File.dirname(__FILE__) + '/../test_helper'
require 'ideas_controller'
require 'mocha'

class IdeasControllerTest < Test::Unit::TestCase
  scenario :basic

  def setup
    @controller = IdeasController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    
    # save the method for the few test cases in which we do want to call it
    IdeasController.send(:alias_method, :tweet_idea_old, :tweet_idea)
    @tweet_idea_expectation = IdeasController.any_instance.expects(:tweet_idea)
    @tweet_idea_expectation.never
  end

  def test_index
    get :index
    assert_response :success
    assert_equal_unordered [@barbershop_discount, @walruses_in_stores, @tranquilizer_guns, @give_up_all_hope], @controller.current_objects
    
    assert_tag    :content => @walruses_in_stores.title
    assert_tag    :content => @barbershop_discount.title
    assert_no_tag :content => @hidden_idea.title
    assert_no_tag :content => @orphan_idea.title
    assert_no_tag :content => @inactive_user_idea.title
  end
  
  def test_index_no_spam
    get :index
    assert_response :success
    assert_equal_unordered [@barbershop_discount, @walruses_in_stores, @tranquilizer_guns, @give_up_all_hope], @controller.current_objects
    
    assert_no_tag :content => @spam_idea.title
  end
  
  def test_search_recent
    get :index, :search => 'recent'
    assert_response :success
    assert_equal_unordered [@barbershop_discount, @walruses_in_stores, @tranquilizer_guns, @give_up_all_hope], @controller.current_objects
  end
  
  def test_search_blank
    get :index, :search_text => ''
    assert_response :success
  end
  
  def test_search_top_rated
    @walruses_in_stores.add_vote!(@quentin)
    get :index, :search => 'top-rated'
    assert_response :success
    assert_equal_unordered [@walruses_in_stores, @barbershop_discount, @tranquilizer_guns, @give_up_all_hope], @controller.current_objects
  end
  
  def test_new
    assert_login_required @quentin, 'You must log in to create new ideas.' do
      get :new
    end
    assert_tag :tag => 'input', :attributes => { :type => "hidden", :name=>"idea[current_id]"  }
    assert_response :success
  end
  
  def test_create_idea_logged_in
    old_ideas = Idea.find(:all)
    login_as @quentin
    post :create,
      :idea => { :title => 'foo', :description => 'bar', :tag_names => 'one two, three' },
      :tags => { -2 => 'five six', 3 => 'seven, three, eight' }  # javascript tags
    assert_redirected_to idea_path(assigns(:idea))
    
    new_ideas = Idea.find(:all) - old_ideas
    assert_equal 1, new_ideas.size
    new_idea = new_ideas.first
    
    assert_equal 'foo', new_idea.title
    assert_equal 'bar', new_idea.description
    assert_equal 'eight, five six, one two, seven, three', new_idea.tag_names
    assert_equal @quentin, new_idea.inventor
  end
  
  def test_create_idea_not_logged_in
    old_ideas = Idea.find(:all)
    post :create, :idea => { :title => 'foo', :description => 'bar' }
      
    # Login required...
    assert_redirected_to :controller => :sessions, :action => :new
    assert_equal 'You must log in to create new ideas.', flash[:info]
    
    # ...but orphan idea still created!
    new_ideas = Idea.find(:all) - old_ideas
    assert_equal 1, new_ideas.size
    new_idea = new_ideas.first
    
    assert_equal 'foo', new_idea.title
    assert_equal 'bar', new_idea.description
    assert_equal nil, new_idea.inventor
    
    assert_equal assign_idea_path(new_idea), session[:return_to]
    assert_equal 'post', session[:return_to_method]
  end
  
  def test_create_idea_and_tweet
    old_ideas = Idea.find(:all)

    @tweet_idea_expectation.at_most_once.returns('stubbed out')

    login_as @tweeter
    post :create,
      :idea => { :title => 'foo', :description => 'bar', :tag_names => 'one two, three' },
      :tags => { -2 => 'five six', 3 => 'seven, three, eight' }  # javascript tags
    assert_redirected_to idea_path(assigns(:idea))
    
    new_ideas = Idea.find(:all) - old_ideas
    assert_equal 1, new_ideas.size
    new_idea = new_ideas.first
    
    assert_equal 'foo', new_idea.title
    assert_equal @tweeter, new_idea.inventor
  end
  
  def test_create_idea_and_twitter_error
    old_ideas = Idea.find(:all)
    
    IdeasController.send(:alias_method, :tweet_idea, :tweet_idea_old)

    #@tweet_idea_expectation.unstub
    # IdeasController.expects(:twitter_oauth)
    Twitter::OAuth.any_instance.expects(:authorize_from_access).raises(Exception, 'twitter unavailable')
    #@tweet_idea_expectation.at_most_once.raises(Exception, 'twitter unavailable')
    Twitter::Base.expects(:new).never
    
    login_as @tweeter
    post :create,
      :idea => { :title => 'foo', :description => 'bar', :tag_names => 'one two, three' },
      :tags => { -2 => 'five six', 3 => 'seven, three, eight' }  # javascript tags
    assert_redirected_to idea_path(assigns(:idea))
    
    new_ideas = Idea.find(:all) - old_ideas
    assert_equal 1, new_ideas.size
    new_idea = new_ideas.first
    
    assert_equal 'foo', new_idea.title
    assert_equal @tweeter, new_idea.inventor
  end
  
  def test_cannot_set_prohibited_fields
    login_as @sally
    old_ideas = Idea.find(:all)
    fake_time = Time.utc(2007, 10, 10)
    post :create, :idea => {
      :title => 'foo',
      :description => 'bar',
      :rating => 100,
      :inventor_id => @quentin.id,
      :created_at => fake_time,
      :updated_at => fake_time,
      :flagged => true,
      :viewed => true,   
      :inappropriate_flags => 10,
      :hidden => true,
      :decayed_at => fake_time
    }
    new_idea = (Idea.find(:all) - old_ideas).first
    assert_not_nil new_idea
    
    assert_not_equal new_idea.rating, 100
    assert_not_equal new_idea.inventor_id, @quentin.id
    assert_not_equal new_idea.created_at, fake_time
    assert_not_equal new_idea.updated_at, fake_time
    assert_not_equal new_idea.flagged, true
    assert_not_equal new_idea.viewed, true
    assert_not_equal new_idea.inappropriate_flags, 10
    assert_not_equal new_idea.hidden, true
    assert_not_equal new_idea.decayed_at, fake_time
  end
  
  def test_create_idea_duplicate_tags
    old_ideas = Idea.find(:all)
    login_as @quentin
    post :create,
      :idea => { :title => 'foo', :description => 'bar', :tag_names => 'three, one two, three, three, three' },
      :tags => { -2 => 'five six', 3 => 'seven, three, eight, three' }  # javascript tags
    assert_redirected_to idea_path(assigns(:idea))
    
    new_ideas = Idea.find(:all) - old_ideas
    assert_equal 1, new_ideas.size
    new_idea = new_ideas.first
    
    assert_equal 'eight, five six, one two, seven, three', new_idea.tag_names
    assert_equal @quentin, new_idea.inventor
  end
  
  def test_assign_idea_owner
    assert_equal nil, @orphan_idea.inventor
    login_as @quentin
    post :assign, :id => @orphan_idea.id
    @orphan_idea.reload
    assert_equal @quentin, @orphan_idea.inventor
    assert_redirected_to idea_path(@orphan_idea)
  end
  
  def test_cannot_reassign_idea_owner
    login_as @quentin
    post :assign, :id => @barbershop_discount.id
    @barbershop_discount.reload
    assert_equal @sally, @barbershop_discount.inventor
  end

  def test_show_idea
    get :show, :id => @walruses_in_stores.id
    assert_response :success
    assert_tag :content => @walruses_in_stores.title
    assert_tag :content => @walruses_in_stores.description
    assert_tag :tag => 'a', :content => @walrus_tag.name,
      :attributes => { :href => idea_search_path(:search => ['tag', @walrus_tag.name]) }
    assert_no_tag :content => @walrus_comment1.text   # inactive user
    assert_tag    :content => @walrus_comment2.text
    assert_no_tag :content => @hidden_comment.text
    assert_no_tag :content => @hidden_idea.title
    assert_no_tag :content => @orphan_idea.title
    assert_no_tag :content => @inactive_user_idea.title
  end
  
  
  def test_show_indicates_duplicates
    get :show, :id => @walruses_in_stores.id
    
    assert_response :success
    assert_tag :attributes => { :class => 'entry-duplicates' },
      :descendant => { :tag => 'a', :content => @duplicate_idea.title, :attributes => { :href => idea_path(@duplicate_idea) }}
    assert_tag :attributes => { :class => 'vote' }
  end
  
  def test_show_indicates_duplicate_of
    get :show, :id => @duplicate_idea.id
    
    assert_response :success
    assert_tag :attributes => { :class => 'info' },
      :descendant => { :tag => 'a', :content => @walruses_in_stores.title, :attributes => { :href => idea_path(@walruses_in_stores) }}
    assert_no_tag :attributes => { :class => /.*vote.*/ }
  end
  
  def test_update_idea_requires_ownership
    login_as @aaron
    assert_raises(RuntimeError) do
      put :update, :id => @walruses_in_stores.id, :idea => { :title => 'oof', :description => 'rab' }
    end
    @walruses_in_stores.reload
    assert_not_equal 'oof', @walruses_in_stores.title
    assert_not_equal 'rab', @walruses_in_stores.description
  end
  
  def test_update_idea
    login_as @quentin
    put :update, :id => @walruses_in_stores.id, :idea => { :title => 'oof', :description => 'rab' }
    assert_redirected_to idea_path(assigns(:idea))
    
    @walruses_in_stores.reload
    assert_equal 'oof', @walruses_in_stores.title
    assert_equal 'rab', @walruses_in_stores.description
  end
  
  def test_orphan_idea_not_shown
    get :show, :id => @orphan_idea.id
    assert_response 410
  end
  
  def test_hidden_idea_not_shown
    get :show, :id => @hidden_idea.id
    assert_response 410
  end
  
  def test_inactive_user_idea_not_shown
    get :show, :id => @inactive_user_idea.id
    assert_response 410
  end
  
  def test_inactive_user_can_see_own_idea
    login_as @inactive_user_idea.inventor
    get :show, :id => @inactive_user_idea.id
    assert_response :success
    assert_tag :content => @inactive_user_idea.title
    # We seem to have got rid of this message:
    # assert_tag :content => /Your idea will not be publicly visible until you confirm your account/i
  end
  
end
