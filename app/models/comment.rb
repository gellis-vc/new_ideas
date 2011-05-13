class Comment < ActiveRecord::Base
  has_rakismet  :author => proc{author.name},
                :author_url=>proc{self.comment_url},
                :author_email => proc{author.email},
        
                :user_ip => :ip,
                :user_agent => :agent,
                :content => :text,
                :permalink=>proc{self.comment_path}
  
  acts_as_authorizable
  
  belongs_to :idea
  belongs_to :author, :class_name => 'User'

  before_create :detect_spam
  after_create :record_contribution
  
  def comment_type
    'comment'
  end

  def comment_path
    "/comment/#{self.id}"
  end
  def comment_url
    Rakismet::URL<<comment_path
  end
  
  validates_presence_of :idea, :author, :text
  validates_presence_of :ip, :on => :create
  validates_presence_of :user_agent, :on => :create
  validate :idea_not_closed
  
  def idea_not_closed
    if !idea.nil? && idea.closed?
      errors.add_to_base("You are trying to comment on an idea within a closed current.  That's not allowed.")
    end
  end
  
  include InappropriateFlag
  unless !Comment.table_exists? 
    acts_as_tsearch :fields=>%w(text)
  end
  
  def detect_spam
    self.marked_spam = self.spam? if Rakismet::KEY
    true
  end
  
  def record_contribution
    author.record_contribution! :comment
  end
  
  def marked_spam=(spam)
    self[:marked_spam] = spam
    self[:hidden] = true if spam
  end
  
  def editing_expired?
    created_at < 15.minutes.ago
  end
  
  def editable_by?(user)
    user == author && !editing_expired?
  end
  
end
