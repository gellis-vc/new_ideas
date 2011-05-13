require File.dirname(__FILE__) + '/../test_helper'
require 'admin/users_controller'

class Admin::UsersControllerTest < Test::Unit::TestCase
  scenario :basic
  
  def setup
    @controller = Admin::UsersController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end
  
  def test_index
    assert_admin_required do
      get :index
    end
    assert_response :success
    assert_template 'admin/users/index'
    assert_tag :attributes => { :onclick => /#{edit_admin_user_path(@aaron)}/ }
    assert_tag :content => @quentin.name
    assert_tag :content => @sally.email
    assert_tag :content => /\s*#{@aaron.zip_code}\s*/
  end
  
  def test_sort
    login_as @admin_user
    get :index, :sort => 'name', :order => 'asc'
    assert_tag :content => @aaron.name, :before => { :content => @quentin.name }
    reset @admin_user
    get :index, :sort => 'name', :order => 'desc'
    assert_tag :content => @aaron.name, :after => { :content => @quentin.name }
    reset @admin_user
    get :index, :sort => 'admin', :order => 'desc'
    assert_tag :content => @admin_user.name, :before => { :content => @aaron.name }
  end
  
  def test_edit
    assert_admin_required do
      get :edit, :id => @sally.id
    end
    assert_response :success
    assert_template 'admin/users/edit'
    assert_tag :tag => 'input', :attributes => { :value => @sally.name  }
    assert_tag :tag => 'input', :attributes => { :value => @sally.email }
    assert_tag :tag => 'input', :attributes => { :value => @sally.zip_code }
  end
  
  def test_update
    assert_admin_required do
      post :update, :id => @sally.id, :user => {
        :name => 'Sally New', :email => 'newsally@example.com',
        :password => 'newpass', :password_confirmation => 'newpass',
        :admin => '1', :moderator => '1' }
    end
    assert_redirected_to edit_admin_user_path(@sally)
    @sally.reload
    assert_equal 'Sally New', @sally.name
    assert @sally.admin?
  end
  
  def test_suspend
    login_as @admin_user
    assert @sally.active?
    put :suspend, :id => @sally.id
    @sally.reload
    assert @sally.suspended?
  end
  
  def test_unsuspend
    login_as @admin_user
    @sally.suspend!
    put :unsuspend, :id => @sally.id
    @sally.reload
    assert !@sally.suspended?
    assert @sally.active?
  end
  
  def test_activate
    login_as @admin_user
    assert !@aaron.active?
    put :activate, :id => @aaron.id
    @aaron.reload
    assert @aaron.active?
  end
  
  def test_edit_admin_privileges
    assert !@sally.admin?
    
    login_as @admin_user
    post :update, :id => @sally.id, :user => {
      :admin => '1', :editor => { :Comment => '1', :LifeCycle => '1'} }

    @sally.reload
    assert @sally.admin?
    assert @sally.has_role?('editor', Comment)
    assert @sally.has_role?('editor', LifeCycle)
    assert !@sally.has_role?('editor', Idea)
    
    post :update, :id => @sally.id, :user => {
      :admin => '1', :editor => { :Comment => '0', :LifeCycle => '1'} }

    @sally.reload
    assert !@sally.has_role?('editor', Comment)
    assert @sally.has_role?('editor', LifeCycle)
    assert !@sally.has_role?('editor', Idea)
  end
  
  def test_revoke_admin
    @sally.has_role 'admin'
    @sally.has_role 'editor', Comment
    
    login_as @admin_user
    post :update, :id => @sally.id,
      :user => { :admin => '0', :editor => { :LifeCycle => '1' } }

    @sally.reload
    assert !@sally.admin?
    assert !@sally.has_role?('editor', Comment)
    assert !@sally.has_role?('editor', LifeCycle)
  end
  
private

  def reset(user)
    setup
    login_as user
  end
  
end
