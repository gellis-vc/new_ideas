require File.dirname(__FILE__) + '/../test_helper'

class LifeCycleTest < Test::Unit::TestCase
  
  scenario :basic

  def test_required_fields
    test_life_cycle_field_error :name, nil
    test_life_cycle_field_error :name, ''
  end
  
  def test_steps_relationship
    assert_equal [@good_idea_review, @good_idea_implement, @good_idea_dance, @good_idea_done], @good_idea.steps
    assert_equal [@bad_idea_mock, @bad_idea_done], @bad_idea.steps
  end
  
  def test_reorder_by_position
    new_order = [@good_idea_implement, @good_idea_review, @good_idea_done, @good_idea_dance]
    new_order.each_with_index do |step, i|
      step.position = i + 1
      step.save!
    end
    @good_idea.steps.reload
    assert_equal new_order, @good_idea.steps
  end
  
  def test_destroy_cascades
    step_ids = @bad_idea.steps.map{ |step| step.id }
    @bad_idea.destroy
    assert_equal [], LifeCycleStep.find(:all, :conditions => { :id => step_ids })
  end
  
private
  
  def test_life_cycle_field_error(field, value)
    test_field_error LifeCycle, field, value, :name => 'foo'
  end
  
end
