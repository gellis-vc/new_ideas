module Admin
  class CurrentsController < AdminController
    
    before_filter :set_body_class
    
    make_resourceful do
      actions :index, :new, :create, :edit, :update
      
      before :create do
        @current.inventor = current_user
      end
      
      before :edit do
        @ideas = Idea.paginate_by_current_id(
          @current_object.id, 
          :page => params[:page], 
          :conditions => ['hidden = ?', false],
          :per_page => params[:per_page] || 20)
      end
      
      response_for :index do |format|
        format.html { render :action => 'index' }
        format.js   { render :partial => 'index' }
      end
      
      response_for :create do |format|
        format.html do
          redirect_to edit_admin_current_path(@current)
        end
        format.js do
          render :template => 'generalized_redirect', :layout => false,
              :locals => { :redirect_path => edit_admin_current_path(@current), :message => 'Creating current...' }
        end
      end
      
      response_for :update do |format|
        format.html do
          flash[:info] = 'Changes saved.'
          redirect_to edit_admin_current_path(@current)
        end
        format.js do
          render :text => 'OK'
        end
      end
    end
    
    include ResourceAdmin
    
  protected

    def default_sort
      ['currents.created_at', true]
    end
    
    def index_query_options
      cols = Current.column_names.collect {|c| "currents.#{c}"}.join(",")
      conditions = {}
      { :select => "#{cols}, count(*) AS idea_count",
        :conditions => conditions,
        :joins => 'LEFT JOIN ideas ON ideas.current_id = currents.id',
        :group => "#{cols}" }
    end
    
    def set_body_class
      @body_class = 'currents'
    end
    
  end
end