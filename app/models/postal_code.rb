class PostalCode < ActiveRecord::Base
  
  def self.find_by_text(text)
    text =~ /\d{5}/
    PostalCode.find(:first, :conditions => { :code => $& })
  end
  
  def readonly?
    true
  end
  
end
