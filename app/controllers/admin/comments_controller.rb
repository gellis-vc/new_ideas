module Admin
  class CommentsController < AdminController
    has_rakismet :only => [:create, :update]
    before_filter :set_body_class
    
    make_resourceful do
      actions :index, :edit, :update
    
      response_for :index do |format|
        format.html { render :action => 'index' }
        format.js   { render :partial => 'index' }
      end
    
      response_for :update do |format|
        format.html do
          flash[:info] = 'Changes saved.'
          redirect_to edit_admin_comment_path(@comment)
        end
        format.js do
          render :text => 'OK'
        end
      end
    end
    
    include ResourceAdmin
    
  protected
    
    def default_sort
      if search_pending_moderation?
        ['inappropriate_flags', true]
      else
        ['comments.created_at', true]
      end
    end
  
    def set_body_class
      @body_class = 'comments'
    end
  end
end
