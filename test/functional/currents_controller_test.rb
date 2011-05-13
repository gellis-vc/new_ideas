require File.dirname(__FILE__) + '/../test_helper'
require 'ideas_controller'
require 'mocha'

class CurrentsControllerTest < Test::Unit::TestCase
  scenario :basic

  def setup
    @controller = CurrentsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_index
    get :index
    assert_response :success  
    # !! should not include @default_current! 
    assert !@controller.current_objects.include?(@default_current)
    [@walrus_attack_current, @orphan_current, @closed_current, @expired_current, @private_current].each {|c| @controller.current_objects.include?(c)}    
    assert_tag    :content => @walrus_attack_current.title
    assert_tag    :content => @walrus_attack_current.description
    assert_tag    :content => @orphan_current.title
    assert_tag    :content => @orphan_current.description    
  end

	# Individual current pages will have some basic stats such as the number of users, ideas, votes, and comments within that Current. 
	# All ideas within this current will be listed in the same format as the other idea pages. Current pages will also be socially sharable through the AddThis widget.  
  def test_show_current
    get :show, :id => @walrus_attack_current.id
    assert_response :success
    assert_tag :content => "Current: #{@walrus_attack_current.title}"
    assert_tag :content => @walrus_attack_current.description
    # ideas count should be 2
    #assert_tag :tag=>'li', :attributes =>{:class=>"ideas"}, :content=>"2"
    
    # Ideas belonging to the current should be listed
    [@tranquilizer_guns, @give_up_all_hope].each do |idea|
      assert_tag :content => idea.title
      assert_tag :content => idea.description
    end

    # Hidden ideas within the current should not show up
    assert @walrus_attack_current.ideas.include?(@hidden_idea)
    #puts assigns(:current_ideas).inspect
    assert !assigns(:current_ideas).include?(@hidden_idea)
    [@hidden_idea].each do |idea|
      assert_no_tag :content => idea.title
      assert_no_tag :content => idea.description
    end  
    
    # should show whether the current is invite_only
    assert_tag
    # should display list of invitees
    
  end
  
  def test_show_current_skips_orphans
    get :show, :id => @default_current.id
    assert_no_tag :content => @orphan_idea.title
  end

end