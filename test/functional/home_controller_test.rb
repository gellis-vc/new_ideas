require File.dirname(__FILE__) + '/../test_helper'
require 'home_controller'

class HomeControllerTest < Test::Unit::TestCase
  def setup
    @controller = HomeController.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
  end
  scenario :basic
  should_route :get, "/", :controller=>'home', :action => 'show'

  context "get show" do
    setup {get :show}
    should_respond_with :success
    should_assign_to(:body_class)
    should_render_template 'show'
  end

  
end
