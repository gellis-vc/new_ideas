require File.dirname(__FILE__) + '/../test_helper'

class RequestTokenTest < ActiveSupport::TestCase

  scenario :oauth
  
  def setup
    @token = RequestToken.create :client_application=>client_applications(:one)
  end

  def test_should_be_valid
    assert @token.valid?
  end
  
  def test_should_not_have_errors
    assert @token.errors.empty?
  end
  
  def test_should_have_a_token
    assert_not_nil @token.token
  end

  def test_should_have_a_secret
    assert_not_nil @token.secret
  end
  
  def test_should_not_be_authorized 
    assert !@token.authorized?
  end

  def test_should_not_be_invalidated
    assert !@token.invalidated?
  end
  
  def test_should_authorize_request
    @token.authorize!(@quentin)
    assert @token.authorized?
    assert_not_nil @token.authorized_at
    assert_equal @quentin, @token.user
  end
  
  def test_should_not_exchange_without_approval
    assert_equal false, @token.exchange!
    assert_equal false, @token.invalidated?
  end
  
  def test_should_exchange
    @token.authorize!(@quentin)
    @token.provided_oauth_verifier=@token.verifier
    @access = @token.exchange!
    assert_not_equal false, @access
    assert @token.invalidated?
    
    assert_equal @quentin, @access.user
    assert @access.authorized?
  end
  
end
