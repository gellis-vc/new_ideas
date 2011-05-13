require File.dirname(__FILE__) + '/../test_helper'
require 'find'

class HtmlEscapingTest < Test::Unit::TestCase
  scenario :xss_attack
  
  # Scans the output of a set of given requests for unescaped HTML (i.e. missing h() calls).
  # This relies on the xss_attack scenario having populated all user-editable text fields of
  # all model objects with text of the form "<attack>model.field</attack>".
  def test_escaping
    idea_fields = attack_fields(:idea, :title, :description)
    admin_idea_fields = idea_fields.dup
    admin_idea_fields[:idea].merge!(:life_cycle_step_id => @life_cycle_step.id)
    user_fields = attack_fields(:user, :name, :password, :zip_code)
    user_fields[:user].merge!(
      :email => 'user@example.com',  # email validity checking prevents attack via address
      :password_confirmation => attack('user.password'),
      :life_cycle_step_ids => [],
      :admin => '1',
      :terms_of_service => '1',
      :editor => { 'Idea' => true, 'LifeCycle' => true, 'User' => true, 'Comment' => true, 'ClientApplication' => true})
    comment_fields = attack_fields(:comment, :text)
    client_app_fields = attack_fields(:name, :url, :callback_url, :support_url)
    current_fields = attack_fields(:title, :description)
    
    # If a request isn't working as expected, add :debug => true as follows:
    # test_request :get,  "/", {}, :debug => true
    
    # Public stuff
    test_request :get,  "/"
    test_request :get,  "/login"
    test_request :get,  "/logout"
    test_request :get,  "/signup"
    test_request :post, "/session", :email => @user.email,         :password => "<attack>user.password<attack>"
    test_request :post, "/session", :email => @pending_user.email, :password => "<attack>pending_user.password<attack>"
    test_request :post, "/session", :email => @user.email,         :password => "wrong password"
    test_request :get,  "/ideas"
    test_request :get,  "/ideas/new"
    test_request :get,  "/ideas/search/recent"
    test_request :get,  "/ideas/search/top-rated"
    test_request :get,  "/ideas/search/tag/#{@tag.name}"
    test_request :get,  "/ideas/#{@idea.id}"
    test_request :post, "/ideas/", idea_fields
    test_request :get,  "/comments"
    test_request :get,  "/ideas/#{@idea.id}/comments"
    test_request :get,  "/ideas/#{@idea.id}/comments/new"
    test_request :post, "/ideas/#{@idea.id}/comments", comment_fields
    test_request :get,  "/profiles/#{@user.id}"
    test_request :get,  "/user/edit"
    test_request :post, "/user", user_fields
    test_request :put,  "/user", user_fields
    test_request :post, "/user/send_activation", :email => @pending_user.email
    test_request :get,  "/user/activate/#{@pending_user.activation_code}"
    test_request :get,  "/user/activate/garbage"
    test_request :get,  "/user/password/forgot"
    test_request :post, "/user/password/forgot", :email => @user.email
    test_request :get,  "/user/password/new/#{@user.activation_code}"
    test_request :get,  "/user/password/new/garbage"
    test_request :get,  "/tags"
    test_request :get,  "/currents"
    test_request :get,  "/currents/#{@current.id}"
    test_request :get,  "/oauth/authorize", :oauth_token => oauth_request_token.token
    test_request :post, "/oauth/authorize", :oauth_token => oauth_request_token.token, :authorize => '1'
    test_request :post, "/oauth/authorize", :oauth_token => oauth_request_token.token, :authorize => '0'
    
    # Admin
    test_request :get,  "/admin/"
    test_request :get,  "/admin/users"
    test_request :get,  "/admin/users/#{@user2.id}/edit"
    test_request :put,  "/admin/users/#{@user2.id}", user_fields
    test_request :get,  "/admin/ideas"
    test_request :get,  "/admin/ideas/#{@idea.id}/edit"
    test_request :put,  "/admin/ideas/#{@idea.id}", admin_idea_fields
    test_request :get,  "/admin/ideas/#{@idea.id}/link_duplicate/#{@idea2.id}"
    test_request :put,  "/admin/bucket/add/#{@idea.id}", idea_fields
    test_request :get,  "/admin/comments"
    test_request :get,  "/admin/comments/#{@comment.id}/edit"
    test_request :put,  "/admin/comments/#{@comment.id}", comment_fields
    test_request :get,  "/admin/life_cycles/edit"
    test_request :get,  "/admin/client_applications"
    test_request :get,  "/admin/client_applications/new"
    test_request :post, "/admin/client_applications", client_app_fields
    test_request :get,  "/admin/client_applications/#{@client_app.id}"
    test_request :get,  "/admin/client_applications/#{@client_app.id}/edit"
    test_request :put,  "/admin/client_applications/#{@client_app.id}", client_app_fields
    test_request :get,  "/admin/currents"
    test_request :get,  "/admin/currents/new"
    test_request :post, "/admin/currents", current_fields
    test_request :get,  "/admin/currents/#{@current.id}/edit"
    test_request :put,  "/admin/currents/#{@current.id}", current_fields
    
    # API
    test_request :get,  "/ideas",                                     :format => 'xml'
    test_request :get,  "/ideas/#{@idea.id}",                         :format => 'xml'
    test_request :get,  "/ideas/#{@idea.id}/comments",                :format => 'xml'
    test_request :get,  "/ideas/#{@idea.id}/comments/#{@comment.id}", :format => 'xml'
    test_request :get,  "/profiles/#{@user.id}",                      :format => 'xml'
    test_request :get,  "/tags",                                      :format => 'xml'
    test_request(:post, "/ideas",                                     :format => 'xml') { oauth_login_as @user } # validation errors
    test_request(:post, "/ideas/#{@idea.id}/vote",                    :format => 'xml') { oauth_login_as @user }
    
    # Misc
    test_request :get,  "/map", :idea_ids => @idea.id.to_s
    test_request :get,  "/about"
    test_request :get,  "/contact"
    test_request :get,  "/terms-of-use"
    test_request :get,  "/privacy-policy"
    
    # TODO: Add tests for RSS that understand the need for double-escaping of certain fields
    
    no_testing_needed 'generalized_redirect.html.haml'
    no_testing_needed 'gone.html.haml'
    no_testing_needed '410.xml.haml'
    no_testing_needed 'home/_cloud.html.haml'
    
    @completed = true
  end

  def setup
    @vulnerabilities = []
    @views_unrendered = {}
    Find.find(view_base_path) do |file|
      if File.file?(file) && !(File.basename(file) =~ /^\./)
        @views_unrendered[file] = true
      end
    end
    ActionView::Template.rendering_test_listener = lambda do |template|
      @views_unrendered[template.filename] = false
    end
  end
  
  def teardown
    if @completed
      @views_unrendered.select{ |k,v| v }.map{ |k,v| k }.sort.each do |file|
        puts "WARNING: no requests in #{self.class} tested the view #{file.gsub(view_base_path, '')}"
      end
    end
    
    unless @vulnerabilities.empty?
      fail "Unsanitized user input detected:" + ([""] + @vulnerabilities).join("\n\t")
    end
  ensure
    ActionView::Template.rendering_test_listener = nil
  end
  
private
  
  def attack(field)
    "<attack>#{field}.updated</attack>"
  end
  
  def attack_fields(obj, *fields)
    h = {}
    fields.each do |f|
      h[f] = attack("#{obj}.#{f}")
    end
    {obj => h}
  end
  
  def test_request(method, path, params = {}, opts = {}, &prep)
    User.transaction do
      @request = ActionController::TestRequest.new
      @response = ActionController::TestResponse.new
      ActionMailer::Base.delivery_method = :test
      ActionMailer::Base.perform_deliveries = true
      ActionMailer::Base.deliveries = []
      
      begin
        @request.env["REQUEST_METHOD"] = method.to_s.upcase
        @request.path = path
        controller_class = ActionController::Routing::Routes.recognize(@request)
        fail "No route for path: #{path}" unless controller_class
        @request.parameters.merge!(params) if params
        @controller = controller_class.new
        
        login_as @user
        prep.call if prep
    
        @controller.process(@request, @response)
      rescue => e
        raise TestRequestException.new(method, path, e)
      end
    
      puts @response.body if opts[:debug]
      find_vulnerabilities @response.body, method, path
      
      ActionMailer::Base.deliveries.each do |email|
        puts email.body if opts[:debug]
        find_vulnerabilities email.body, method, path, "(in email)"
      end
      raise ActiveRecord::Rollback
    end
  end
  
  def find_vulnerabilities(text, req_method, req_path, note = '')
    text.scan(/<attack>(.*)<\/?attack>/i) do |vulnerable_field|
      @vulnerabilities << "Request: #{req_method.to_s.upcase} #{req_path}\t\tField: #{vulnerable_field} #{note}"
    end
  end
  
  def no_testing_needed(view_path)
    @views_unrendered[File.expand_path(view_base_path + '/' + view_path)] = false
  end
  
  def view_base_path
    File.expand_path(File.dirname(__FILE__) + '/../../app/views')
  end
  
  def oauth_request_token
    @client_app.create_request_token
  end
  
  class TestRequestException < Exception
    def initialize(method, path, e)
      super "While processing #{method.to_s.upcase} #{path}\n#{e.class}: #{e.message}"
      set_backtrace e.backtrace
    end
  end
  
end

# Nasty hack to record which templates are rendered, hopefully without breaking other tests
module ActionView
  class Template
    alias_method :original_render_template, :render_template
    cattr_accessor :rendering_test_listener
    
    def render_template(*args)
      rendering_test_listener.call(self) if rendering_test_listener
      original_render_template(*args)
    end
  end
end
