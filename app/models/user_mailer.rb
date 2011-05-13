class UserMailer < ActionMailer::Base
  def signup_notification(user)
    setup_email(user)
    @subject    += 'Please activate your new account'
    @body[:url]  = activate_url(:activation_code => user.activation_code)
  end
  
  def activation(user)
    setup_email(user)
    @subject    += 'Your account has been activated!'
    @body[:url]  = root_url
  end
  
  def password_reset(user)
    setup_email(user)
    @subject += 'Password reset'
    @body[:url] = password_reset_url(:activation_code => user.activation_code)
  end
  
  def comment_notification(user, comment)
    setup_email(user)
    @subject += 'Your idea has received a comment'
    @body[:comment] = comment
    @body[:url] = idea_url(comment.idea)
  end
  
  def life_cycle_notification(user, life_cycle_step)
    setup_email(user)
    @subject += "New idea requiring attention in #{life_cycle_step.name}"
    @body[:life_cycle_step] = life_cycle_step
    @body[:url] = admin_root_url
  end
  
  protected
    def setup_email(user)
      @recipients  = "#{user.email}"
      @from        = BBYIDX::SHORT_SITE_NAME
      @subject     = "[#{BBYIDX::SHORT_SITE_NAME.upcase}] "
      @sent_on     = Time.now
      @body[:user] = user
    end
end
