class ProfilesController < ApplicationController
  
  def show
    @body_class = 'profile'
    @user = User.find(params[:id])
    
    if BBYIDX::TWITTER_ENABLED && !@user.twitter_handle.blank?
      status = Timeout::timeout(3) do
        @twitter_description = Twitter.user(@user.twitter_handle).description
      end
    end
    
    if @user.active? || @user == current_user
      respond_to do |format|
        format.html
        format.xml
      end
    else
      resource_gone
    end
  end
    
end
