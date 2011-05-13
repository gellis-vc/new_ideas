require File.dirname(__FILE__) + '/../test_helper'
require 'users_controller'

class InappropriateControllerTest < Test::Unit::TestCase
  scenario :basic

  def setup
    @controller = InappropriateController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end
  
  def test_flag_idea
    get :flag, :model => 'idea', :id => @walruses_in_stores.id
    
    [@walruses_in_stores, @walrus_comment1, @walrus_comment2].each { |m| m.reload }
    assert_equal 1, @walruses_in_stores.inappropriate_flags
    assert_equal 0, @walrus_comment1.inappropriate_flags
    assert_equal 0, @walrus_comment2.inappropriate_flags
  end
  
  def test_flag_comment
    get :flag, :model => 'comment', :id => @walrus_comment1.id
    
    [@walruses_in_stores, @walrus_comment1, @walrus_comment2].each { |m| m.reload }
    assert_equal 0, @walruses_in_stores.inappropriate_flags
    assert_equal 1, @walrus_comment1.inappropriate_flags
    assert_equal 0, @walrus_comment2.inappropriate_flags
  end
  
  def test_attack_blocked
    assert_raises RuntimeError do
      get :flag, :model => 'user', :id => @sally.id
    end
  end

end
