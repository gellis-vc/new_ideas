require File.dirname(__FILE__) + '/../test_helper'
require 'comments_controller'

class CommentsControllerTest < Test::Unit::TestCase
  scenario :basic

  def setup
    @controller = CommentsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end
  
  def test_index
    get :index
    assert_response :success
    assert_template 'comments/index'
    assert_no_tag :content => @walrus_comment1.text         # inactive user
    assert_tag :content => @walrus_comment2.text            # active user
    assert_no_tag :content => @hidden_comment.text          # comment hidden
    assert_no_tag :content => @comment_on_hidden_idea.text  # idea hidden
    assert_tag :tag => 'a', :attributes => { :href => idea_path(@walruses_in_stores) }
  end

  def test_new
    assert_login_required @quentin, 'You must log in to create new comments.' do
      get :new, :idea_id => @walruses_in_stores.id
    end
    assert_response :success
  end
  
  def test_create_comment
    old_count = Comment.count
    assert_login_required @quentin, 'You must log in to create new comments.' do
      post :create, :idea_id => @walruses_in_stores.id,
        :comment => { :text => 'foobar', :idea_id => @walruses_in_stores.id }
    end
    assert_equal old_count + 1, Comment.count
  
    assert_redirected_to idea_path(@walruses_in_stores)
  end
  
  def test_cannot_set_prohibited_fields
    login_as @sally
    old_comments = Comment.find(:all)
    fake_time = Time.utc(2007, 10, 10)
    post :create, :idea_id => @walruses_in_stores.id, :comment => {
      :text => 'foobar',
      :idea_id => @walruses_in_stores.id,
      :author_id => @quentin.id,
      :created_at => fake_time,
      :updated_at => fake_time,
      :inappropriate_flags => 100,
      :hidden => true
    }
    new_comment = (Comment.find(:all) - old_comments).first
    assert_not_nil new_comment
    
    assert_equal 'foobar', new_comment.text
    assert_equal @walruses_in_stores, new_comment.idea
    
    assert_not_equal new_comment.author_id, @quentin.id
    assert_not_equal new_comment.created_at, fake_time
    assert_not_equal new_comment.updated_at, fake_time
    assert_not_equal new_comment.inappropriate_flags, 10
    assert_not_equal new_comment.hidden, true
  end
  
  def test_update_comment
    assert_login_required @aaron, 'You must log in to edit comments.' do
      put :update, :id => @walrus_comment1.id,
        :comment => { :text => 'foobar' }
    end
    assert_equal  'foobar', @walrus_comment1.reload.text
    
    assert_equal @walruses_in_stores, assigns(:idea)
    
    assert_redirected_to idea_path(@walruses_in_stores)
  end
  
  def test_update_comment_non_owner
    assert_login_required @quentin, 'You must log in to edit comments.' do
      put :update, :id => @walrus_comment1.id,
        :comment => { :text => 'foobar' }
    end
    
    assert_not_equal  'foobar', @walrus_comment1.reload.text
  end
  
end
