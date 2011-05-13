class CommentObserver < ActiveRecord::Observer
  
  def after_create(comment)
    UserMailer.deliver_comment_notification(comment.idea.inventor, comment) if comment.idea.inventor.notify_on_comments?
  end
  
end
