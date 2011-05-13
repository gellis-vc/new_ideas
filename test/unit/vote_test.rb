require File.dirname(__FILE__) + '/../test_helper'

class VoteTest < Test::Unit::TestCase
  
  scenario :basic
  
  def test_unique_constraint
    Vote.create!(:idea => @walruses_in_stores, :user => @aaron)
    assert_raises(ActiveRecord::RecordInvalid) do
      Vote.create!(:idea => @walruses_in_stores, :user => @aaron)
    end
  end
  
  def test_validate_current_not_closed_when_adding_comment
    my_vote = Vote.new(:idea=>@tranquilizer_guns, :user => @sally) 
    @tranquilizer_guns.stubs(:closed?).returns(true)    
    assert_equal false, my_vote.save
    assert_equal "You are trying to vote on an idea within a closed current.  That's not allowed.", my_vote.errors[:base]
  end
end
