require File.dirname(__FILE__) + '/../test_helper'

class Admin::LifeCyclesControllerTest < Test::Unit::TestCase
  scenario :basic
  
  def setup
    @controller = Admin::LifeCyclesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end
  
  def test_edit
    assert_admin_required 'You must log in as an administrator to edit life cycles in the admin interface.' do
      get :edit
    end
    
    # It's really impossible to test the full functionality of this page without driving a browser through it,
    # because so much of it is JS. Let's just make sure that the basic stuff showed up.
    
    [@good_idea, @bad_idea].each do |life_cycle|
      assert_select '.in_place_editor_field#?', "life_cycle_name_#{life_cycle.id}_in_place_editor", :count => 1, :text => life_cycle.name
      assert_select 'ol.life-cycle-steps#?', "life_cycle_#{life_cycle.id}" do
        life_cycle.steps.each do |step|
          assert_select 'li.step#?', "step_#{step.id}" do
            assert_select '.delete'
            assert_select '.reorder'
            assert_select 'span#?', "life_cycle_step_name_#{step.id}_in_place_editor", :count => 1, :text => step.name
          end
        end
      end
    end
  end
  
  def test_update_life_cycle_name
    assert_admin_required do
      post :set_life_cycle_name, :id => @good_idea.id, :value => 'Grand idea'
    end
    @good_idea.reload
    assert_equal 'Grand idea', @good_idea.name
  end
  
  def test_update_life_cycle_name_validation
    login_as @admin_user
    post :set_life_cycle_name, :id => @good_idea.id, :value => ''
    @good_idea.reload
    assert_equal 'Good idea', @good_idea.name
  end
  
  def test_update_life_cycle_step_name
    assert_admin_required do
      post :set_life_cycle_step_name, :id => @good_idea_implement.id, :value => 'Make it so'
    end
    @good_idea_implement.reload
    assert_equal 'Make it so', @good_idea_implement.name
  end
  
  def test_update_life_cycle_step_name_validation
    login_as @admin_user
    post :set_life_cycle_step_name, :id => @good_idea_implement.id, :value => ''
    @good_idea_implement.reload
    assert_equal 'Implement everywhere', @good_idea_implement.name
  end
  
  def test_reorder
    new_order = [@good_idea_dance, @good_idea_done, @good_idea_review, @good_idea_implement]
    assert_admin_required do
      post :reorder, :id => @good_idea.id, "life_cycle_#{@good_idea.id}" => new_order.map{ |step| step.id }
    end
    @good_idea.steps.reload
    assert_equal new_order, @good_idea.steps
  end
  
  def test_create_life_cycle
    life_cycles = LifeCycle.find(:all)
    assert_admin_required do
      post :create, :value => 'Wackiness'
    end
    new_life_cycles = LifeCycle.find(:all) - life_cycles
    assert_equal 1, new_life_cycles.size
    new_life_cycle = new_life_cycles.first
    assert_equal 'Wackiness', new_life_cycle.name
    assert_equal ['DONE'], new_life_cycle.steps.map{ |step| step.name }
  end
  
  def test_create_life_cycle_invalid
    life_cycles = LifeCycle.find(:all)
    login_as @admin_user
    post :create, :value => ''
    new_life_cycles = LifeCycle.find(:all) - life_cycles
    assert_equal [], new_life_cycles
  end
  
  def test_create_step
    steps = LifeCycleStep.find(:all)
    assert_admin_required do
      post :create_step, :id => @bad_idea, :value => 'Do a happy dance'
    end
    new_steps = LifeCycleStep.find(:all) - steps
    assert_equal 1, new_steps.size
    new_step = new_steps.first
    assert_equal 'Do a happy dance', new_step.name
    assert_equal [@bad_idea_mock, new_step, @bad_idea_done], @bad_idea.steps
  end
  
  def test_create_step_invalid
    steps = LifeCycleStep.find(:all)
    login_as @admin_user
    post :create_step, :id => @bad_idea, :value => ''
    new_steps = LifeCycleStep.find(:all) - steps
    assert_equal [], new_steps
  end
  
  def test_delete_and_reassign
    assert_admin_required do
      delete :delete, :id => @good_idea.id, :reassign_to => @bad_idea_mock.id
    end
    assert_equal_unordered [@bad_idea], LifeCycle.find(:all)
    assert_equal_unordered @bad_idea.steps, LifeCycleStep.find(:all)
    @walruses_in_stores.reload
    assert_equal @bad_idea_mock, @walruses_in_stores.life_cycle_step
  end
  
  def test_delete_reassign_to_null
    login_as @admin_user
    delete :delete, :id => @good_idea.id, :reassign_to => ''
    assert_equal_unordered [@bad_idea], LifeCycle.find(:all)
    assert_equal_unordered @bad_idea.steps, LifeCycleStep.find(:all)
    @walruses_in_stores.reload
    assert_equal nil, @walruses_in_stores.life_cycle_step
  end
  
  def test_delete_step_and_reassign
    assert_admin_required do
      delete :delete_step, :id => @good_idea_dance.id, :reassign_to => @good_idea_implement.id
    end
    @good_idea.steps.reload
    assert_equal_unordered [@good_idea_review, @good_idea_implement, @good_idea_done], @good_idea.steps
    @walruses_in_stores.reload
    assert_equal @good_idea_implement, @walruses_in_stores.life_cycle_step
  end
  
  def test_delete_step_reassign_to_null
    assert_admin_required do
      delete :delete_step, :id => @good_idea_dance.id, :reassign_to => ''
    end
    @good_idea.steps.reload
    assert_equal_unordered [@good_idea_review, @good_idea_implement, @good_idea_done], @good_idea.steps
    @walruses_in_stores.reload
    assert_equal nil, @walruses_in_stores.life_cycle_step
  end
  
end
