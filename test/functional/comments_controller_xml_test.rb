require File.dirname(__FILE__) + '/../test_helper'
require 'comments_controller'
require 'nokogiri'

class CommentsControllerXmlTest < Test::Unit::TestCase
  scenario :basic
  
  def setup
    @controller = CommentsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end
  
  def test_create_requires_oauth
    post_xml :create, :idea_id => @barbershop_discount.id, :comment => { :text => 'baz' }
    assert_response 401
    
    login_as @sally  # normal login should NOT work for XML!
    post_xml :create, :idea_id => @barbershop_discount.id, :comment => { :text => 'baz' }
    assert_response 401
  end
  
  def test_create
    all_comments = Comment.find(:all)
    xml = post_xml :create, oauth_params(@sally, @phone_app, :idea_id => @barbershop_discount.id, :comment => { :text => 'baz' })
    assert_response :success
    new_comments = Comment.find(:all) - all_comments
    assert_equal 1, new_comments.count
    new_comment = new_comments.first
    
    assert_equal @barbershop_discount, new_comment.idea
    
    assert_xml_equal xml, '/comment/id',                  new_comment.id
    assert_xml_equal xml, '/comment/idea-id',             new_comment.idea.id
    assert_xml_equal xml, '/comment/created-at',          new_comment.created_at
    assert_xml_equal xml, '/comment/text',                'baz'
    assert_xml_equal xml, '/comment/inappropriate-flags', 0
    assert_xml_equal xml, '/comment/author/id',           @sally.id
    assert_xml_equal xml, '/comment/author/name',         @sally.name
  end
  
  def test_create_fails
    all_comments = Comment.find(:all)
    xml = post_xml :create, oauth_params(@sally, @phone_app, :idea_id => @barbershop_discount.id, :comment => { :text => '' })
    assert_response :success
    new_comments = Comment.find(:all) - all_comments
    assert_equal 0, new_comments.count
    
    expected_errors = [['text', 'Text', "can't be blank"]]
    
    match_xml_to_array(xml, '/validation-errors/error', expected_errors) do |error_xml, error|
      assert_xml_equal error_xml, './field',              error[0]
      assert_xml_equal error_xml, './field-display-name', error[1]
      assert_xml_equal error_xml, './message',            error[2]
    end
  end
end
