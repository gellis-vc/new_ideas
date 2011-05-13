class UserObserver < ActiveRecord::Observer
  
  def after_create(user)
   # UserMailer.deliver_signup_notification(user) if user.activation_code
  end

  def after_save(user)
    #UserMailer.deliver_activation(user) if user.recently_activated?
  end
  
end
