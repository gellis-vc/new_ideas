require File.dirname(__FILE__) + '/../test_helper'

class UserTest < Test::Unit::TestCase
  # Be sure to include AuthenticatedTestHelper in test/test_helper.rb instead.
  # Then, you can remove it from this and the functional test.
  include AuthenticatedTestHelper
  
  scenario :basic

  def test_should_create_user
    assert_difference 'User.count' do
      user = create_user
      assert !user.new_record?, "#{user.errors.full_messages.to_sentence}"
    end
  end

  def test_should_initialize_activation_code_upon_creation
    user = create_user
    user.reload
    assert_not_nil user.activation_code
  end

  def test_should_create_and_start_in_pending_state
    user = create_user
    user.reload
    assert user.pending?
  end
  
  def test_should_require_name
    assert_no_difference 'User.count' do
      u = create_user(:name => nil)
      assert u.errors.on(:name)
    end
  end
  
  def test_should_require_not_excessively_long_name
    assert_no_difference 'User.count' do
      u = create_user(:name => 'a'*101)
      assert u.errors.on(:name)
    end
  end
  
  def test_should_require_password
    assert_no_difference 'User.count' do
      u = create_user(:password => nil)
      assert u.errors.on(:password)
    end
  end

  def test_should_require_password_confirmation
    assert_no_difference 'User.count' do
      u = create_user(:password_confirmation => nil)
      assert u.errors.on(:password_confirmation)
    end
  end

  def test_should_require_email
    assert_no_difference 'User.count' do
      u = create_user(:email => nil)
      assert u.errors.on(:email)
    end
  end
  
  def test_should_require_valid_email
    assert_no_difference 'User.count' do
      u = create_user(:email => "bogus")
      assert u.errors.on(:email)
      u = create_user(:email => "bogus@example.com/")
      assert u.errors.on(:email)
      u = create_user(:email => "$bogus@example.com")
      assert u.errors.on(:email)
    end
  end

  def test_should_require_zip
    assert_no_difference 'User.count' do
      u = create_user(:zip_code => nil)
      assert u.errors.on(:zip_code)
    end
  end

  def test_should_require_terms_of_service_present
    assert_no_difference 'User.count' do
      u = create_user(:terms_of_service => nil)
      assert u.errors.on(:terms_of_service)
    end
  end

  def test_should_require_terms_of_service_checked
    assert_no_difference 'User.count' do
      u = create_user(:terms_of_service => '0')
      assert u.errors.on(:terms_of_service)
    end
  end

  def test_should_reset_password
    users(:quentin).update_attributes(:password => 'new password', :password_confirmation => 'new password')
    assert_equal users(:quentin), User.authenticate('quentin@example.com', 'new password')
  end

  def test_should_not_rehash_password
    users(:quentin).update_attributes(:email => 'quentin2@example.com')
    assert_equal users(:quentin), User.authenticate('quentin2@example.com', 'test')
  end

  def test_should_authenticate_user
    assert_equal users(:quentin), User.authenticate('quentin@example.com', 'test')
  end

  def test_should_set_remember_token
    users(:quentin).remember_me
    assert_not_nil users(:quentin).remember_token
    assert_not_nil users(:quentin).remember_token_expires_at
  end

  def test_should_unset_remember_token
    users(:quentin).remember_me
    assert_not_nil users(:quentin).remember_token
    users(:quentin).forget_me
    assert_nil users(:quentin).remember_token
  end

  def test_should_remember_me_for_one_week
    before = 1.week.from_now.utc
    users(:quentin).remember_me_for 1.week
    after = 1.week.from_now.utc
    assert_not_nil users(:quentin).remember_token
    assert_not_nil users(:quentin).remember_token_expires_at
    assert users(:quentin).remember_token_expires_at.between?(before, after)
  end

  def test_should_remember_me_until_one_week
    time = 1.week.from_now.utc
    users(:quentin).remember_me_until time
    assert_not_nil users(:quentin).remember_token
    assert_not_nil users(:quentin).remember_token_expires_at
    assert_equal users(:quentin).remember_token_expires_at, time
  end

  def test_should_remember_me_default_two_weeks
    before = 2.weeks.from_now.utc
    users(:quentin).remember_me
    after = 2.weeks.from_now.utc
    assert_not_nil users(:quentin).remember_token
    assert_not_nil users(:quentin).remember_token_expires_at
    assert users(:quentin).remember_token_expires_at.between?(before, after)
  end

  def test_should_register_passive_user
    user = create_user(:password => nil, :password_confirmation => nil)
    assert_equal 'passive', user.state
    assert user.passive?
    user.update_attributes(:password => 'new password', :password_confirmation => 'new password')
    user.register!
    assert user.pending?
  end

  def test_should_suspend_user
    users(:quentin).suspend!
    assert users(:quentin).suspended?
  end

  def test_suspended_user_should_not_authenticate
    users(:quentin).suspend!
    assert_not_equal users(:quentin), User.authenticate('quentin', 'test')
  end

  def test_should_unsuspend_user_to_active_state
    users(:quentin).suspend!
    assert users(:quentin).suspended?
    users(:quentin).unsuspend!
    assert users(:quentin).active?
  end

  def test_should_unsuspend_user_with_nil_activation_code_and_activated_at_to_passive_state
    users(:quentin).suspend!
    User.update_all :activation_code => nil, :activated_at => nil
    assert users(:quentin).suspended?
    users(:quentin).reload.unsuspend!
    assert users(:quentin).passive?
  end

  def test_should_unsuspend_user_with_activation_code_and_nil_activated_at_to_pending_state
    users(:quentin).suspend!
    User.update_all :activation_code => 'foo-bar', :activated_at => nil
    assert users(:quentin).suspended?
    users(:quentin).reload.unsuspend!
    assert users(:quentin).pending?
  end

  def test_should_delete_user
    assert_nil users(:quentin).deleted_at
    users(:quentin).delete!
    assert_not_nil users(:quentin).deleted_at
    assert users(:quentin).deleted?
  end
  
  def test_should_distinguish_admin
    assert @admin_user.admin?
    assert !@sally.admin?
  end
  
  def test_make_admin_via_flag
    @sally.admin = true
    @sally.save!
    
    @sally.reload
    assert @sally.admin?
  end
  
  def test_revoke_admin_via_flag
    @admin_user.admin = false
    @admin_user.save!
    
    @admin_user.reload
    assert !@admin_user.admin?
  end
  
  def test_top_contributors
    assert_equal_unordered [@quentin, @sally, @tweeter], User.find_top_contributors
    assert_equal [@quentin], User.find_top_contributors(:limit => 1)
  end
  
  def test_life_cycle_step_relationship
    assert_equal_unordered [@good_idea_dance, @bad_idea_mock], @admin_user.life_cycle_steps
    assert_equal_unordered [], @sally.life_cycle_steps
  end
  
  def test_matches_postal_code
    assert_equal '55101', @quentin.postal_code.code
    assert_equal '55102', @aaron.postal_code.code
    assert_equal nil,     @sally.postal_code
  end

protected
  
  def create_user(options = {})
    record = User.new(
      {
        :name => 'S. Quire',
        :email => 'quire@example.com',
        :password => 'quire',
        :password_confirmation => 'quire',
        :zip_code => '55401',
        :terms_of_service => '1'
      }.merge(options))
    record.register! if record.valid?
    record
  end
end
