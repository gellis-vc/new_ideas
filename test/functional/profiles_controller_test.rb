require File.dirname(__FILE__) + '/../test_helper'
require 'users_controller'

class ProfilesControllerTest < Test::Unit::TestCase
  scenario :basic

  def setup
    @controller = ProfilesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_show
    # Login NOT required -- profile is public!
    get :show, :id => @quentin.id
    assert_response :success
    assert_tag :content => @quentin.name
    assert_no_tag :content => @quentin.email # not for public!
  end
  
  def test_show_includes_ideas_invented
    get :show, :id => @quentin.id
    assert_response :success
    assert_tag :tag => 'a', :attributes => { :href => idea_path(@walruses_in_stores) }
    assert_no_tag :tag => 'a', :attributes => { :href => idea_path(@barbershop_discount) }
  end
  
  def test_show_excludes_hidden_ideas
    assert_equal @sally, @hidden_idea.inventor
    get :show, :id => @sally.id
    assert_response :success
    assert_no_tag :tag => 'a', :attributes => { :href => idea_path(@hidden_idea) }
  end
  
  def test_show_excludes_spam_ideas
    assert_equal @quentin, @spam_idea.inventor
    get :show, :id => @quentin.id
    assert_response :success
    assert_no_tag :tag => 'a', :attributes => { :href => idea_path(@spam_idea) }
  end
  
  def test_show_includes_comments_posted
    get :show, :id => @sally.id
    assert_response :success
    assert_tag :tag => 'a', :attributes => { :href => idea_path(@walruses_in_stores) }
    assert_tag :content => @walrus_comment2.text
  end
  
  def test_show_excludes_hidden_comments
    assert_equal @sally, @hidden_comment.author
    get :show, :id => @sally.id
    assert_response :success
    assert_no_tag :content => @hidden_comment.text
  end
  
  def test_show_excludes_spam_comments
    assert_equal @sally, @walrus_comment_spam.author
    @walrus_comment_spam.text = 'foo'  # spam has funky chars, which make it hard to do a nonexistence search with confidence!
    @walrus_comment_spam.save!
    
    get :show, :id => @sally.id
    assert_response :success
    assert_no_tag :content => @walrus_comment_spam.text
  end
  
  def test_show_includes_votes_cast
    @barbershop_discount.add_vote!(@quentin)
    get :show, :id => @quentin.id
    assert_response :success
    assert_tag :tag => 'a', :attributes => { :href => idea_path(@barbershop_discount) }
  end
  
  def test_inactive_user_not_shown
    get :show, :id => @aaron.id
    assert_response 410
  end
  
  def test_inactive_user_can_see_own_profile
    login_as @aaron
    get :show, :id => @aaron.id
    assert_response :success
  end
  
end
