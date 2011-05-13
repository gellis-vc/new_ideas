module AuthenticatedTestHelper
  # Sets the current user in the session and controller
  def login_as(user)
    @controller.test_login_as(user)
  end
  
  def oauth_login_as(user)
    @controller.test_oauth_login_as(user)
  end

  def authorize_as(user)
    @request.env["HTTP_AUTHORIZATION"] = user ? ActionController::HttpAuthentication::Basic.encode_credentials(users(user).login, 'test') : nil
  end
end
