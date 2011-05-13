module Admin
  class HomeController < AdminController
  
    def show
      @body_class = 'admin-home'
      if current_user.moderator
        @inapp_ideas, @inapp_comments = [Idea, Comment].map do |current_model|
          paginate_pending_moderation(current_model, 10)
        end
        Idea.populate_comment_counts @inapp_ideas
        Tag.load_tags @inapp_ideas
        AdminTag.load_tags @inapp_ideas
      end
    end
    
    def ideas_for_step(step)
      Idea.paginate(
        :conditions => ['life_cycle_step_id = ?', step.id],
        :order => 'created_at',
        :page => params[:page],
        :per_page => params[:per_page] || 10)
    end
    helper_method :ideas_for_step
  
    def request_as_words
      "use the admin interface"
    end
    
  end
end
