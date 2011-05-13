require 'timeout'

class IdeasController < ApplicationController

  # Authentication
  before_filter :login_required, :except => [:index, :show, :create]      # create not included here b/c it will redirect to login page AFTER saving
  before_filter :oauthenticate, :unless => :logged_in?                    # If no other login was applied, use oauth if present
  
  # Authorization
  before_filter :check_visibility, :only => [:show]
  before_filter :check_ownership, :only => [:update]
  
  # Content cleanup & population
  before_filter :strip_example_text
  before_filter :add_search_feed, :only => :index
  before_filter :add_comments_feed, :only => [:show, :update]
  
  param_accessible :idea => [:title, :description, :tag_names, :current_id]
  
  make_resourceful do
    actions :new, :create, :show, :update
    
    before :create do
      @idea.inventor = current_user
      if params[:tags]
        @idea.tags += params[:tags].values.map{ |tag| Tag.from_string(tag) }.flatten
      end
    end
    
    after :create do
      if @idea.valid? && @idea.inventor
        # Users automatically vote for their own ideas:
        @idea.add_vote!(@idea.inventor)
        
        if BBYIDX::TWITTER_ENABLED && @idea.inventor.tweet_ideas?
          begin
            tweet_idea(@idea)
          rescue Exception  => exception
            puts("Exception raised tweeting idea with id: #{@idea.id}, '#{exception}'")
            #TODO: error recovery if the tweet fails? For now it just silently fails.
          end
        end
        
        if BBYIDX::FACEBOOK_ENABLED && @idea.inventor.is_facebook_user?
          begin
            facebook_publish_idea(@idea)
          rescue Exception  => exception
            puts("Exception raised facebooking idea with id: #{@idea.id}, '#{exception}'")
            #TODO: error recovery if the facebook fails?  For now it just silently fails.
          end
        end
      end
    end
    
    response_for :show do |format|
      format.html
      format.xml
    end
    
    response_for :create do |format|
      format.html do
        if @idea.inventor
          redirect_to idea_path(@idea)
        else
          login_required assign_idea_path(@idea), :post
        end
      end
      format.js do
        if @idea.inventor
          render :template => 'generalized_redirect', :layout => false,
            :locals => { :redirect_path => idea_path(@idea), :message => 'Creating idea...' }
        else
          login_required assign_idea_path(@idea), :post
        end
      end
      format.xml do
        render :template => 'ideas/show'
      end
    end
    
    response_for :create_fails do |format|
      format.html { render :template => 'ideas/new' }
      format.js   { render :partial => 'new' }
      format.xml  { render :template => 'validation_errors' }
    end
    
    response_for :update do |format|
      format.html do
        redirect_to idea_path(@idea)
      end
      format.js do
        render :template => 'generalized_redirect', :layout => false,
          :locals => { :redirect_path => idea_path(@idea), :message => 'Updating idea...' }
      end
    end
    
    response_for :update_fails do |format|
      format.js { render :partial => 'edit' }
    end
    
  end
  
  # Assigns the owner of an orphaned idea after the user has logged in.
  def assign
    Idea.transaction do
      @idea = current_object
      @idea.lock!
      @idea.inventor ||= current_user
      @idea.save!
      @idea.add_vote!(@idea.inventor)
    end
    redirect_to idea_path(@idea)
  end
  
  def index
    if params[:page_size]
      page_size = params[:page_size].to_i
      params[:page_size] = 1 if page_size < 1
      params[:page_size] = 50 if page_size > 50
    end
    
    # Call current_objects to populate @body_class. (If the results are cached, we don't need to do this.
    # We never cache the idea list for a user who is logged in, because we want their votes to show up immediately.)
    unless !logged_in? && fragment_exist?(['idea_search', CGI.escape(params.inspect)])
      current_objects
    end
    
    respond_to do |format|
      format.html
      format.rss { render :content_type => 'application/rss+xml'}
      format.xml
    end
  end
  
  def current_objects
    @currents ||= Idea.populate_comment_counts(search_ideas(params))
  end
  
  def check_visibility
    @idea = current_object
    resource_gone unless @idea.visible? || logged_in? && @idea.inventor_id == current_user.id
  end
  
  def check_ownership
    raise "Cannot modify idea you did not create" if !idea_owner?(current_object)
  end
  
  def add_search_feed
    if params[:search]
      current_objects
      @feeds << {
        :href => idea_search_url(params[:search], :format => :rss),
        :title => "#{BBYIDX::LONG_SITE_NAME}: #{ERB::Util.h @query_title}" }
    end
  end
  
  def add_comments_feed
    @feeds << {
      :href => idea_comments_url(current_object, :format => :rss),
      :title => "#{BBYIDX::LONG_SITE_NAME}: Comments on \"#{ERB::Util.h(ERB::Util.h current_object.title)}\"" }
  end
  
  include ApplicationHelper
  include TwitterHelper
  helper_method :has_voted?
  helper_method :idea_owner?
  helper_method :flagged_as_inappropriate?

private 
  
  # In case Javascript failed to remove example text (IE has trouble with this), we strip it here.
  # example_text.js appends \xA0 (a non-breaking space) to distinguish example text. If we see that
  # on a param, out it goes!
  def strip_example_text
    if params[:idea]
      params[:idea].each_key do |key|
        params[:idea][key] = '' if params[:idea][key] =~ /\xA0$/
      end
    end
  end
  
  def facebook_publish_idea(idea)
      link_data = [{
        :text => "View More at #{BBYIDX::SHORT_SITE_NAME}",
        :href => idea_url(idea)
      }].to_json
      attachment_data = {
        :description => idea.description,
        :media => [ { :type => "image", :src => "#{root_url}images/logo_blue.jpg", :href => idea_url(idea) } ]
      }.to_json
      
      flash[:facebook_publish] = "facebook_publish_stream( 'has an idea for #{BBYIDX::SHORT_SITE_NAME}: #{idea.title}', #{attachment_data}, #{link_data});"
  end
  
  def tweet_idea(idea)
    status = Timeout::timeout(3) do
      twitter_oauth.authorize_from_access(idea.inventor.twitter_token, idea.inventor.twitter_secret)
      twitter = Twitter::Base.new(twitter_oauth)
    
      twitter_string = "My idea: #{idea_url(idea)} #{idea.title}"
      
      twitter.update(twitter_string.slice(0,139))
    end
  end
  
end
