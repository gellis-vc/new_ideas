require File.dirname(__FILE__) + '/../test_helper'
require 'votes_controller'
require 'nokogiri'

class VotesControllerXmlTest < Test::Unit::TestCase
  scenario :basic
  
  def setup
    @controller = VotesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_create_requires_oauth
    post_xml :create, :idea_id => @barbershop_discount
    assert_response 401
    
    login_as @quentin  # normal login should NOT work for XML!
    post_xml :create, :idea_id => @barbershop_discount
    assert_response 401
  end
  
  def test_create
    old_votes = @barbershop_discount.votes
    xml = post_xml :create, oauth_params(@quentin, @phone_app, :idea_id => @barbershop_discount)
    assert_response :success
    new_votes = @barbershop_discount.votes - old_votes
    assert_equal 1, old_votes.count
    
    @barbershop_discount.reload
    assert_xml_equal xml, '/vote/idea-rating', @barbershop_discount.rating
  end
  
end
