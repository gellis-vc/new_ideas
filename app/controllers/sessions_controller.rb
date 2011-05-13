# This controller handles login/logout functionality.
class SessionsController < ApplicationController
  
  include AuthenticatedSystem

  def new
    @body_class = 'login'
  end

  def create
    user = User.find_by_login(params[:email], params[:password])
    if user
      self.current_user = user
      if params[:remember_me] == "1"
        current_user.remember_me unless current_user.remember_token?
        cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
      end
      redirect_back_or_default do
        if user.active?
          redirect_to '/'
        else
          render :action => 'inactive'
        end
      end
    else
      flash.now[:error] = render_to_string :partial => 'login_failed'
      render :action => 'new'
    end
  end

  def destroy
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    flash[:info] = "You are now logged out. Thanks for using #{BBYIDX::SHORT_SITE_NAME}!"
    redirect_back_or_default('/')
  end

end
