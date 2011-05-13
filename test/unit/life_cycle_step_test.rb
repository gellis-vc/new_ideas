require File.dirname(__FILE__) + '/../test_helper'

class LifeCycleStepTest < Test::Unit::TestCase
  
  scenario :basic

  def test_required_fields
    test_life_cycle_step_field_error :name, nil
    test_life_cycle_step_field_error :name, ''
    test_life_cycle_step_field_error :life_cycle, nil
  end
  
  def test_life_cycle_relationship
    assert_equal @good_idea, @good_idea_review.life_cycle
    assert_equal 3, @good_idea_dance.position
  end
  
  def test_user_relationship
    assert_equal [], @good_idea_implement.admins
    assert_equal [@admin_user], @good_idea_dance.admins
  end
  
  def test_follows
    assert @good_idea_implement.follows?(@good_idea_review)
    assert @bad_idea_done.follows?(@bad_idea_mock)
    assert !@good_idea_review.follows?(@good_idea_implement)
    assert !@good_idea_implement.follows?(@bad_idea_mock)
  end
  
private
  
  def test_life_cycle_step_field_error(field, value)
    test_field_error LifeCycleStep, field, value,
      :name => 'foo', :life_cycle => @good_idea
  end
  
end
