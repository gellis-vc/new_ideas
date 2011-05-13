require File.dirname(__FILE__) + '/../test_helper'
require 'admin/ideas_controller'

class Admin::HomeControllerTest < Test::Unit::TestCase
  scenario :basic
  
  def setup
    @controller = Admin::HomeController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end
  
  def test_show_includes_pending_moderation
    @walruses_in_stores.flag_as_inappropriate!
    assert_admin_required 'You must log in as an administrator to use the admin interface.' do
      get :show
    end
    assert_response :success
    assert_tag :content => @walruses_in_stores.title
    assert_no_tag :content => @barbershop_discount.title
  end
  
end