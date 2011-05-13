require File.dirname(__FILE__) + '/../test_helper'
require 'tags_controller'

class TagsControllerTest < Test::Unit::TestCase
  scenario :basic

  def setup
    @controller = TagsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_index
    get :index
    assert_response :success
    
    assert_tag_link @crazy_tag, 400
    assert_tag_link @walrus_tag, 100
  end
  
private

  def assert_tag_link(tag, size)
    assert_tag :tag => 'a',
      :content => /#{tag.name}/,
      :attributes => {
        :href => idea_search_path(:search => ['tag', tag.name])} do
      
      assert_tag :content => "\(#{tag.ideas.size}\)"
    end
  end
  
end
