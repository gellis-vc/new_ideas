require File.dirname(__FILE__) + '/../test_helper'
require 'ideas_controller'
require 'nokogiri'

class IdeasControllerXmlTest < Test::Unit::TestCase
  scenario :basic
  
  def setup
    @controller = IdeasController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end
  
  def test_show
    xml = get_xml :show, :id => @walruses_in_stores.id
    assert_response :success
    assert_xml_equal xml, '/idea/id',                   @walruses_in_stores.id
    assert_xml_equal xml, '/idea/created-at',           @walruses_in_stores.created_at
    assert_xml_equal xml, '/idea/inappropriate-flags',  @walruses_in_stores.inappropriate_flags
    assert_xml_equal xml, '/idea/rating',               @walruses_in_stores.rating.round.to_i
    assert_xml_equal xml, '/idea/title',                @walruses_in_stores.title
    assert_xml_equal xml, '/idea/description',          @walruses_in_stores.description
    assert_xml_equal xml, '/idea/inventor/id',          @walruses_in_stores.inventor.id
    assert_xml_equal xml, '/idea/inventor/name',        @walruses_in_stores.inventor.name
    assert_xml_equal xml, '/idea/duplicate-of',         nil
    assert_xml_equal xml, '/idea/comment-count',        nil
    
    match_xml_to_array(xml, '/idea/comments/comment', @walruses_in_stores.comments) do |comment_xml, comment|
      assert_xml_equal comment_xml, './id',                  comment.id
      assert_xml_equal comment_xml, './inappropriate-flags', comment.inappropriate_flags
      assert_xml_equal comment_xml, './author/id',           comment.author.id
      assert_xml_equal comment_xml, './author/name',         comment.author.name
    end
    
    match_xml_to_array(xml, '/idea/tags/tag', @walruses_in_stores.tags) do |tag_xml, tag|
      assert_xml_equal tag_xml, './id',   tag.id
      assert_xml_equal tag_xml, './name', tag.name
    end
  end
  
  def test_show_duplicate
    xml = get_xml :show, :id => @duplicate_idea
    assert_xml_equal xml, '/idea/id',                 @duplicate_idea.id
    assert_xml_equal xml, '/idea/title',              @duplicate_idea.title
    assert_xml_equal xml, '/idea/duplicate-of/id',    @walruses_in_stores.id
    assert_xml_equal xml, '/idea/duplicate-of/title', @walruses_in_stores.title
  end
  
  def test_show_reflects_vote
    xml = get_xml :show, oauth_params(@quentin, @phone_app, :id => @barbershop_discount)
    assert_xml_equal xml, '/idea/user-has-voted', false
    
    @barbershop_discount.add_vote!(@quentin)
    
    setup  # reset everything, because controller caches votes!
    xml = get_xml :show, oauth_params(@quentin, @phone_app, :id => @barbershop_discount)
    assert_xml_equal xml, '/idea/user-has-voted', true
  end
  
  def test_index
    xml = get_xml :index
    expected_ideas = [@give_up_all_hope, @tranquilizer_guns, @barbershop_discount, @walruses_in_stores]
    assert_xml_equal xml, '/ideas/@first-index', 0
    assert_xml_equal xml, '/ideas/@page-size', 20
    assert_xml_equal xml, '/ideas/@count', expected_ideas.count
    assert_xml_equal xml, '/ideas/@total-count', expected_ideas.count
    match_xml_to_array(xml, '/ideas/idea', expected_ideas) do |idea_xml, idea|
      assert_xml_equal idea_xml, './id',                   idea.id
      assert_xml_equal idea_xml, './inappropriate-flags',  idea.inappropriate_flags
      assert_xml_equal idea_xml, './rating',               idea.rating.round.to_i
      assert_xml_equal idea_xml, './title',                idea.title
      assert_xml_equal idea_xml, './description',          idea.description
      assert_xml_equal idea_xml, './inventor/id',          idea.inventor.id
      assert_xml_equal idea_xml, './inventor/name',        idea.inventor.name
      assert_xml_equal idea_xml, './comment-count',        idea.comments.visible.size
      assert_xml_equal idea_xml, './comments',             nil
      assert_xml_equal idea_xml, './duplicate-of',         nil
      assert_xml_equal idea_xml, './has-voted',            nil
    end
  end
  
  def test_index_reflects_votes
    xml = get_xml :index, oauth_params(@quentin, @phone_app)
    walrus_xml     = xml.xpath("/ideas/idea[id=#{@walruses_in_stores.id}]")[0]
    barbershop_xml = xml.xpath("/ideas/idea[id=#{@barbershop_discount.id}]")[0]
    assert_xml_equal walrus_xml,     './user-has-voted', true  # quentin created walrus idea, and thus counts as having voted for it
    assert_xml_equal barbershop_xml, './user-has-voted', false
  end
  
  def test_pagination
    xml = get_xml :index, :page_size => 2, :page => 2
    expected_ideas = [@barbershop_discount, @walruses_in_stores]
    assert_xml_equal xml, '/ideas/@first-index', 2
    assert_xml_equal xml, '/ideas/@page-size', 2
    assert_xml_equal xml, '/ideas/@count', 2
    assert_xml_equal xml, '/ideas/@total-count', 4
    match_xml_to_array(xml, '/ideas/idea', expected_ideas) do |idea_xml, idea|
      assert_xml_equal idea_xml, './id',                   idea.id
    end
  end
  
  def test_pagination_refuses_huge_page_size
    xml = get_xml :index, :page_size => 1000, :page => 1
    assert_xml_equal xml, '/ideas/@page-size', 50
  end
  
  def test_xml_create_requires_oauth
    post_xml :create, :idea => { :title => 'foo', :description => 'bar', :tag_names => 'one two, three' }
    assert_response 401
    
    login_as @quentin  # normal login should NOT work for XML!
    post_xml :create, :idea => { :title => 'foo', :description => 'bar', :tag_names => 'one two, three' }
    assert_response 401
  end
  
  def test_create
    all_ideas = Idea.find(:all)
    xml = post_xml :create,
      oauth_params(
        @quentin, @phone_app,
        :idea => { :title => 'foo', :description => 'bar', :tag_names => 'one two, three' })
    assert_response :success
    new_ideas = Idea.find(:all) - all_ideas
    assert_equal 1, new_ideas.count
    new_idea = new_ideas.first
    
    assert_xml_equal xml, '/idea/id',                   new_idea.id
    assert_xml_equal xml, '/idea/inappropriate-flags',  0
    assert_xml_equal xml, '/idea/rating',               1
    assert_xml_equal xml, '/idea/title',                'foo'
    assert_xml_equal xml, '/idea/description',          'bar'
    assert_xml_equal xml, '/idea/inventor/id',          @quentin.id
    assert_xml_equal xml, '/idea/inventor/name',        @quentin.name
  end
  
  def test_create_fails
    login_as @quentin
    all_ideas = Idea.find(:all)
    xml = post_xml :create,
      oauth_params(
        @quentin, @phone_app,
        :idea => { :title => (1..1000).to_a.join, :description => '', :tag_names => 'one two, three' })
    assert_response :success
    assert_equal [], Idea.find(:all) - all_ideas, 'Request should not have created any new ideas'
    
    expected_errors = [
      ['title', 'Title', "is too long (maximum is 120 characters)"],
      ['description', 'Description', "can't be blank"]]
    
    match_xml_to_array(xml, '/validation-errors/error', expected_errors) do |error_xml, error|
      assert_xml_equal error_xml, './field',              error[0]
      assert_xml_equal error_xml, './field-display-name', error[1]
      assert_xml_equal error_xml, './message',            error[2]
    end
  end

end
