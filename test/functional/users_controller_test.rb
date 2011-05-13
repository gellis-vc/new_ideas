require File.dirname(__FILE__) + '/../test_helper'
require 'users_controller'

class UsersControllerTest < Test::Unit::TestCase
  scenario :basic

  def setup
    @controller = UsersController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @deliveries = ActionMailer::Base.deliveries = []
  end

  def test_should_allow_signup
    assert_difference 'User.count' do
      create_user
      assert_response :redirect
      assert flash[:info]
      assert logged_in?  # Logged in even though not active, because user can still create an idea
      assert_equal 1, @deliveries.size
      assert_email_sent current_user, /#{activate_path(current_user.activation_code)}/
    end
  end

  def test_should_require_password_on_signup
    assert_no_difference 'User.count' do
      create_user(:password => nil)
      assert assigns(:user).errors.on(:password)
      assert_response :success
      assert !logged_in?
      assert_equal 0, @deliveries.size
    end
  end

  def test_should_require_password_confirmation_on_signup
    assert_no_difference 'User.count' do
      create_user(:password_confirmation => nil)
      assert assigns(:user).errors.on(:password_confirmation)
      assert_response :success
      assert !logged_in?
      assert_equal 0, @deliveries.size
    end
  end

  def test_should_require_email_on_signup
    assert_no_difference 'User.count' do
      create_user(:email => nil)
      assert assigns(:user).errors.on(:email)
      assert_response :success
      assert !logged_in?
      assert_equal 0, @deliveries.size
    end
  end
  
  def test_should_sign_up_user_in_pending_state
    create_user
    assigns(:user).reload
    assert assigns(:user).pending?
  end

  def test_should_sign_up_user_with_activation_code
    create_user
    assigns(:user).reload
    assert_not_nil assigns(:user).activation_code
  end

  def test_should_send_activation
    post :send_activation, :email => 'aaron@example.com'
    assert_response :redirect
    assert flash[:info] =~ /aaron@example.com/
    assert !logged_in?
    assert_equal 1, @deliveries.size
    assert_email_sent @aaron, /#{activate_path(@aaron.activation_code)}/
  end
  
  def test_should_activate_user
    assert_nil User.authenticate('aaron', 'test')
    assert !@aaron.active?
    
    get :activate, :activation_code => users(:aaron).activation_code
    
    assert_redirected_to '/'
    assert flash[:info] =~ /activat/i
    assert_equal @aaron, current_user
    @aaron.reload
    assert @aaron.active?
  end
  
  def test_should_not_activate_user_with_wrong_key
    get :activate, :activation_code => 'frutso'
    assert_nil flash[:notice]
    assert_template 'bad_activation_code'
    @aaron.reload
    assert !@aaron.active?
  end

  def test_should_not_activate_user_with_blank_key
    get :activate, :activation_code => ''
    assert_nil flash[:notice]
    assert_template 'bad_activation_code'
    @aaron.reload
    assert !@aaron.active?
  end
  
  def test_should_render_password_reset_form
    get :forgot_password
    assert_response :success
    assert_template 'forgot_password'
  end
  
  def test_should_send_password_reset_email
    post :send_password_reset, :email => 'quentin@example.com'
    assert_response :success
    assert_template 'password_reset_sent'
    assert !logged_in?
    assert_equal 1, @deliveries.size
    assert_email_sent @quentin, /#{password_reset_path(@quentin.activation_code)}/
  end
  
  def test_should_not_send_password_reset_with_bad_email
    post :send_password_reset, :email => 'frutso@example.com'
    assert_response :success
    assert_template 'forgot_password'
    assert assigns(:not_found)
    assert_tag :content => /not in our database/
    assert_equal 0, @deliveries.size
  end
  
  def test_should_allow_new_password
    get :new_password, :activation_code => users(:aaron).activation_code
    
    assert_redirected_to edit_user_path
    assert flash[:info] =~ /password/i
    assert_equal @aaron, current_user
    @aaron.reload
    assert @aaron.active?
  end
  
  def test_should_edit
    login_as @quentin
    get :edit
    assert_response :success
    assert_template 'edit'
    assert_tag :tag => 'input', :attributes => {:value => @quentin.name}
    assert_no_tag :attributes => {:value => 'test'} # password should not be visible
  end
  
  def test_edit_requires_login
    get :edit
    assert_response :redirect
  end
  
  def test_should_update
    login_as @quentin
    post :update, :user => { :name => 'New Quentin', :password => 'newpass', :password_confirmation => 'newpass' }
    assert_response :success
    assert flash[:info]
    assert User.authenticate('quentin@example.com', 'newpass')
    @quentin.reload
    assert_equal 'New Quentin', @quentin.name
    assert_nil User.authenticate('quentin@example.com', 'test')
  end

  def test_update_requires_login
    post :update, :user => { :password => 'newpass', :password_confirmation => 'newpass' }
    assert_response :redirect
    assert User.authenticate('quentin@example.com', 'test') # old pass still in effect
  end

  def test_should_ignore_attempt_to_update_other_user
    login_as @quentin
    post :update, :user_id => @aaron.id, :user => { :id => @aaron.id, :password => 'newpass', :password_confirmation => 'newpass' }
    assert User.find_by_login('quentin@example.com', 'newpass')
    assert User.find_by_login('aaron@example.com', 'test') # unmodified
  end
  
  protected
    def create_user(options = {})
      post :create, :user =>
        {
          :name => 'S. Quire',
          :email => 'quire@example.com',
          :zip_code => '55402',
          :password => 'quire',
          :password_confirmation => 'quire',
          :terms_of_service => '1'
        }.merge(options)
    end
    
    def current_user
      session[:user_id] ? User.find(session[:user_id]) : nil
    end
    
    def logged_in?
      !current_user.nil?
    end
    
    def assert_email_sent(user, *body_pats)
      fail "Expected email to have been sent by controller" if @deliveries.empty?
      sent = @deliveries.shift
      assert_equal [user.email], sent.to
      body_pats.each do |body_pat|
        assert sent.body =~ body_pat, "Expected #{body_pat.inspect} in email body, but didn't find it.\n\nEmail body:\n\n#{sent.body}\n"
      end
    end
end
