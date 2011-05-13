require File.dirname(__FILE__) + '/../test_helper'
require 'votes_controller'

class VotesControllerTest < Test::Unit::TestCase
  scenario :basic

  def setup
    @controller = VotesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_create_vote
    old_count = Vote.count
    old_rating = @walruses_in_stores.rating
    
    assert_login_required @sally, 'You must log in to vote for ideas.' do
      post :create, :idea_id => @walruses_in_stores.id
    end
    
    @walruses_in_stores.reload
    assert_equal old_count + 1, Vote.count
    assert_equal old_rating + 1, @walruses_in_stores.rating
  
    assert_redirected_to idea_path(@walruses_in_stores)
  end
  
end
