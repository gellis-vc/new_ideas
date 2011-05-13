require File.dirname(__FILE__) + '/../test_helper'
require 'users_controller'
require 'nokogiri'

class ProfilesControllerXmlTest < Test::Unit::TestCase
  scenario :basic

  def setup
    @controller = ProfilesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_show
    xml = get_xml :show, :id => @sally.id
    assert_response :success
    
    assert_xml_equal xml, '/profile/id',                   @sally.id
    assert_xml_equal xml, '/profile/name',                 @sally.name
    assert_xml_equal xml, '/profile/created-at',           @sally.created_at
    assert_xml_equal xml, '/profile/contribution-points',  @sally.contribution_points.to_i
    assert_xml_equal xml, '/profile/admin',                false
    
    match_xml_to_array(xml, '/profile/ideas/idea', [@duplicate_idea, @barbershop_discount]) do |idea_xml, idea|
      assert_xml_equal idea_xml, './id', idea.id
    end
    
    match_xml_to_array(xml, '/profile/comments/comment', [@walrus_comment2]) do |comment_xml, comment|
      assert_xml_equal comment_xml, './id', comment.id
    end
  end
  
  def test_show_omits_private info
    xml_str = get_xml(:show, :id => @quentin.id).to_s
    %w(email id).each do |property|
      assert_false xml_str.include?(quentin.send(property.to_sym)), "User XML should not include #{property}"
    end
  end
end
