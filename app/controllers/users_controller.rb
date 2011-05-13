class UsersController < ApplicationController
  include AuthenticatedSystem
  
  before_filter :login_required, :only => [:edit, :update]
  before_filter :populate_user, :except => [:show]

  def new
  end

  def create
    cookies.delete :auth_token
    @user = User.new(params[:user])
    if @user.valid?
      @user.register!
      self.current_user = @user
      flash[:info] = render_to_string(:partial => 'created')
      redirect_back_or_default('/')
    else
      render :action => 'new'
    end
  end

  def activate
    if log_in_with_activation_code
      flash[:info] = "Your account is now activated!"
      redirect_back_or_default('/')
    else
      render :action => 'bad_activation_code'
    end
  end
  
  def send_activation
    @user = User.find_by_email(params[:email])
    raise "No such user" unless @user
    @user.reset_activation_code unless @user.activation_code
    UserMailer.deliver_signup_notification(@user)
    flash[:info] = render_to_string(:partial => 'created')
    redirect_back_or_default('/')
  end

  def forgot_password
  end
  
  def send_password_reset
    if params[:email].blank?
      @missing = true
    else
      user = User.find_by_email(params[:email])
      if user
        user.reset_activation_code
        user.save!
        UserMailer.deliver_password_reset(user)
        return render(:action => 'password_reset_sent')
      else
        @not_found = true
      end
    end
    render :action => 'forgot_password'
  end
  
  def new_password
    if log_in_with_activation_code
      flash[:info] = "Please choose a new password."
      redirect_to :action => 'edit'
    else
      render :action => 'bad_activation_code'
    end
  end
  
  def edit
    render :action => 'edit'
  end
  
  def update
    # TODO: Should we require confirmation process if email changes?
    @user.update_attributes(params[:user])
    if @user.save
      flash.now[:info] = "Your changes have been saved."
      @user.password = @user.password_confirmation = nil
      
      if (! @user.twitter_handle.blank?) && @user.tweet_ideas?
        twitter_oauth.set_callback_url(authorize_twitter_url)

        session['rtoken']  = twitter_oauth.request_token.token
        session['rsecret'] = twitter_oauth.request_token.secret

        redirect_to twitter_oauth.request_token.authorize_url
        return
      end
    end
    
    render :action => 'edit'
  end
  
  def authorize_twitter
      #TODO: add handling for errors form authorization
      
      if params[:denied].blank?
        twitter_oauth.authorize_from_request(session['rtoken'], session['rsecret'], params[:oauth_verifier])

        session['rtoken']  = nil
        session['rsecret'] = nil

        # twitter = Twitter::Base.new(twitter_oauth)
        # twitter.update("Testing from rails")

        @user.twitter_token = twitter_oauth.access_token.token
        @user.twitter_secret = twitter_oauth.access_token.secret
      
        if @user.save
          flash.now[:info] = "Your account has been linked to twitter."
        end
      else
        @user.tweet_ideas = false
        @user.save
        flash.now[:info] = "Your account was not linked to twitter."
      end
      render :action => 'edit'
  end
  
  def disconnect
    if current_user.is_facebook_user?
      current_user.fb_uid = nil
      if current_user.save
        flash[:notice] = 'Your account has been disconnected from facebook'
      end
    end
    render :action => 'edit'
  end
  
  include TwitterHelper
  
protected

  def populate_user
    @user = current_user
  end
  
  def log_in_with_activation_code
    unless params[:activation_code].blank?
      code = params[:activation_code].gsub(/[^\w]/, '')  # Remove any whitespace/garbage the user accidentally copied
      self.current_user = User.find_by_activation_code(code)
      if logged_in? && !current_user.active?
        current_user.activate!
      end
    end
    logged_in?
  end

end
