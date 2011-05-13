module TwitterHelper
  
  def twitter_oauth
    @twitter_oauth ||= Twitter::OAuth.new(TWITTER_CONFIG['key'], TWITTER_CONFIG['secret'], :sign_in => true)
  end
  
end
