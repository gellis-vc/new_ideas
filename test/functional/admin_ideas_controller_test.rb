require File.dirname(__FILE__) + '/../test_helper'
require 'admin/ideas_controller'

class Admin::IdeasControllerTest < Test::Unit::TestCase
  scenario :basic
  
  def setup
    @controller = Admin::IdeasController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end
  
  def test_index
    assert_admin_required 'You must log in as an administrator to view ideas in the admin interface.' do
      get :index
    end
    assert_response :success
    assert_template 'admin/ideas/index'
    assert_tag :attributes => { :onclick => /#{edit_admin_idea_path(@walruses_in_stores)}/ }
    assert_tag :content => @barbershop_discount.title
    assert_tag :content => @barbershop_discount.description
    assert_tag :content => @barbershop_discount.tag_names
    assert_tag :content => @barbershop_discount.admin_tag_names
    assert_tag :tag => 'a', :attributes => { :href => new_idea_path }
  end
  
  # Spam should be displayed along with non-spam if params[:spam] == "true"
  def test_spam
    assert_admin_required 'You must log in as an administrator to view ideas in the admin interface.' do
      get :index, {:marked_spam => "true"}
    end
    assert_response :success
    assert_template 'admin/ideas/index'
    assert_tag :attributes => { :onclick => /#{edit_admin_idea_path(@spam_idea)}/ }
    
    # spam should be displayed
    assert_tag :content => @spam_idea.title
    assert_tag :content => @spam_idea.description
    assert_tag :content => @spam_idea.tag_names
    assert_tag :content => @spam_idea.admin_tag_names

    # non-spam should be displayed too
    assert_tag :content => @walruses_in_stores.title
    assert_tag :content => @barbershop_discount.title
  end
  
  def test_search
    assert_admin_required do
      get :index, :search => 'barbershop'
    end
    assert_tag :content => @barbershop_discount.title
    assert_no_tag :content => @walruses_in_stores.title
  end
  
  def test_search_spam_filter
    assert_admin_required do
      get :index, :search => "maximize"
    end
    assert_tag :content => @barbershop_discount.title
    assert_no_tag :content => @spam_idea.title
  end
  
  def test_search_spam_included
    assert_admin_required do
      get :index, :search => "maximize", :marked_spam=>"true"
    end
    assert_tag :content => @barbershop_discount.title
    assert_tag :content => @spam_idea.title
  end
  
  def test_search_multiword
    login_as @admin_user
    get :index, :search => 'quartet discounts'
    assert_tag :content => @barbershop_discount.title
    assert_no_tag :content => @walruses_in_stores.title
  end
  
  def test_search_by_life_cycle
    assert_admin_required do
      get :index, :life_cycle_step => @good_idea_dance.id
    end
    assert_tag :content => @walruses_in_stores.title
    assert_no_tag :content => @barbershop_discount.title
  end
  
  def test_search_by_life_cycle_and_text_with_results
    assert_admin_required do
      get :index, :life_cycle_step => @good_idea_dance.id, :search => 'walruses'
    end
    assert_tag :content => @walruses_in_stores.title
    assert_no_tag :content => @barbershop_discount.title
  end  
  
  def test_search_by_life_cycle_and_text_no_results
    get :index, :life_cycle_step => @good_idea_dance.id, :search => 'barbershop'
    assert_no_tag :content => @walruses_in_stores.title
    assert_no_tag :content => @barbershop_discount.title
  end
  
  def test_sort
    reset @admin_user
    get :index
    assert_tag :content => @barbershop_discount.title, :before => { :content => @walruses_in_stores.title }
    
    reset @admin_user
    get :index, :sort => 'ideas.title', :order => 'desc'
    assert_tag :content => @barbershop_discount.title, :after => { :content => @walruses_in_stores.title }
    
    reset @admin_user
    get :index, :sort => 'comment_count', :order => 'desc'
    assert_tag :content => @barbershop_discount.title, :after => { :content => @walruses_in_stores.title }
  end
  
  def test_edit
    assert !@walruses_in_stores.viewed
    assert_admin_required do
      get :edit, :id => @walruses_in_stores.id
    end
    assert_response :success
    assert_template 'admin/ideas/edit'
    assert_tag :tag => 'input', :attributes => { :value => @walruses_in_stores.title  }
    assert_tag :tag => 'textarea', :content => @walruses_in_stores.description
    assert_tag :tag => 'input', :attributes => { :value => @walruses_in_stores.tag_names }
    assert_tag :tag => 'option', :content=>@walrus_attack_current.title,:attributes => { :value => @walrus_attack_current.id}
    @walruses_in_stores.reload
    assert @walruses_in_stores.viewed
  end
  
  def test_life_cycle_selection_for_unassigned
    assert_admin_required do
      get :edit, :id => @barbershop_discount.id
    end
    assert_life_cycle_ui_correct []
  end
  
  def test_life_cycle_selection_for_assigned
    assert_admin_required do
      get :edit, :id => @walruses_in_stores.id
    end
    assert_life_cycle_ui_correct [@good_idea_review, @good_idea_implement]
  end
  
  def test_empty_life_cycle_not_listed
    empty_life_cycle = LifeCycle.create!(:name => 'Empty')
    assert_admin_required do
      get :edit, :id => @walruses_in_stores.id
    end
    assert_tag    :tag => 'option', :content => @good_idea.name
    assert_no_tag :tag => 'option', :content => empty_life_cycle.name
  end
  
  def test_update
    assert_admin_required do
      post :update, :id => @walruses_in_stores.id, :idea => {
        :title => 'No Walruses', :description => 'Walruses begone!',
        :tag_names => 'walrussy, refutation', :admin_tag_names => 'zoology',
        :life_cycle_step_id => @bad_idea_mock.id }
    end
    assert_redirected_to edit_admin_idea_path(@walruses_in_stores)
    @walruses_in_stores.reload
    assert_equal 'No Walruses', @walruses_in_stores.title
    assert_equal 'Walruses begone!', @walruses_in_stores.description
    refutation_tag = Tag.find_by_name('refutation')
    zoology_tag = AdminTag.find_by_name('zoology')
    assert refutation_tag
    assert zoology_tag
    assert_equal_unordered [@walrus_tag, refutation_tag], @walruses_in_stores.tags
    assert_equal_unordered [zoology_tag], @walruses_in_stores.admin_tags
    assert_equal @bad_idea_mock, @walruses_in_stores.life_cycle_step
  end
  
  def test_update_requires_modify_privilege
    @admin_user.has_no_role 'editor', Idea
    login_as @admin_user
    post :update, :id => @barbershop_discount.id, :idea => {
      :title => 'Down with Barbershop Quartets', :description => 'Charge them extra!!',
      :tag_names => 'music, refutation', :admin_tag_names => 'grumpuses',
      :life_cycle_step_id => @bad_idea_mock.id }
    assert_redirected_to login_path
    assert_equal 'You do not have the necessary privileges to edit ideas in the admin interface.', flash[:info]
  end
  
  def test_update_with_admin_comment
    assert_admin_required do
      post :update, :id => @walruses_in_stores.id, :admin_comment => {
        :text => 'admin comment'
      }
    end
    assert_redirected_to edit_admin_idea_path(@walruses_in_stores)
    @walruses_in_stores.reload
    comment = @walruses_in_stores.admin_comments.first
    assert comment
    assert !comment.new_record?
    assert_equal 'admin comment', comment.text
    assert_equal @admin_user, comment.author
  end
  
  def test_update_with_blank_admin_comment
    assert_admin_required do
      post :update, :id => @walruses_in_stores.id, :admin_comment => {
        :text => ''
      }
    end
    assert_redirected_to edit_admin_idea_path(@walruses_in_stores)
    assert assigns(:idea).errors.empty?
    assert @walruses_in_stores.reload.admin_comments.empty?
  end
  
  def test_link_duplicates_creates_relationship
    assert_nil @walruses_in_stores.duplicate_of
    assert_nil @barbershop_discount.duplicate_of
    assert_equal_unordered [@duplicate_idea], @walruses_in_stores.duplicates
    assert_equal_unordered [], @barbershop_discount.duplicates
    
    assert_admin_required do
      post :link_duplicates, :id => @walruses_in_stores.id, :other_id => @barbershop_discount
    end
    
    @walruses_in_stores.reload
    @barbershop_discount.reload
    assert_nil @walruses_in_stores.duplicate_of
    assert_equal @walruses_in_stores, @barbershop_discount.duplicate_of
    assert_equal_unordered [@barbershop_discount, @duplicate_idea], @walruses_in_stores.duplicates
    assert_equal_unordered [], @barbershop_discount.duplicates
  end
  
  def test_link_duplicates_transfers_votes
    @walruses_in_stores.add_vote!(@quentin)
    @barbershop_discount.add_vote!(@sally)
    @walruses_in_stores.rating = 100
    @walruses_in_stores.save!
    @barbershop_discount.rating = 10
    @barbershop_discount.save!
    
    assert_admin_required do
      post :link_duplicates, :id => @walruses_in_stores.id, :other_id => @barbershop_discount
    end
    
    @walruses_in_stores.reload
    @barbershop_discount.reload
    assert_equal 110, @walruses_in_stores.rating
    assert_equal 10, @barbershop_discount.rating
    assert_equal_unordered [@sally, @quentin], @walruses_in_stores.voters
    assert_equal_unordered [@sally], @barbershop_discount.voters
  end
  
  def test_link_duplicates_accounts_for_user_voting_for_parent_and_child
    @walruses_in_stores.add_vote!(@quentin)
    @barbershop_discount.add_vote!(@sally)
    @barbershop_discount.add_vote!(@quentin)
    @walruses_in_stores.rating = 100
    @walruses_in_stores.save!
    @barbershop_discount.rating = 10
    @barbershop_discount.save!
    
    assert_admin_required do
      post :link_duplicates, :id => @walruses_in_stores.id, :other_id => @barbershop_discount
    end
    
    @walruses_in_stores.reload
    @barbershop_discount.reload
    assert_equal 105, @walruses_in_stores.rating
    assert_equal 5, @barbershop_discount.rating
    assert_equal_unordered [@sally, @quentin], @walruses_in_stores.voters
    assert_equal_unordered [@sally, @quentin], @barbershop_discount.voters
  end
  
  def test_unlink_duplicates
    @walruses_in_stores.add_vote!(@quentin)
    @walruses_in_stores.add_vote!(@sally)
    @walruses_in_stores.rating = 110
    @walruses_in_stores.save!
    @duplicate_idea.add_vote!(@sally)
    @duplicate_idea.rating = 10
    @duplicate_idea.save!
    
    assert_admin_required do
      post :update, :id => @duplicate_idea.id, :clear_duplicate => '1'
    end
    
    @walruses_in_stores.reload
    @duplicate_idea.reload
    assert_nil @duplicate_idea.duplicate_of
    assert_equal [], @walruses_in_stores.duplicates
    assert_equal 10, @duplicate_idea.rating
    assert_equal 100, @walruses_in_stores.rating
    assert_equal_unordered [@quentin], @walruses_in_stores.voters
    assert_equal_unordered [@sally], @duplicate_idea.voters
  end
  
private

  def reset(user)
    setup
    login_as user
  end
  
  def assert_life_cycle_ui_correct(checked_steps)
    assert_select 'select#life_cycle_handler_life_cycle', 1 do |selects|
      assert_options(
        ['', @good_idea.id,   @bad_idea.id],
        ['', @good_idea.name, @bad_idea.name],
        checked_steps.map{ |step| step.life_cycle_id }.uniq)
    end
    [@good_idea, @bad_idea].each do |life_cycle|
      assert_select "ol#life_cycle_#{life_cycle.id}" do |ol|
        life_cycle.steps.each do |step|
          assert_select "li#step_#{step.id}" do
            assert_select "input#life_cycle_handler_step_#{step.id}[type=checkbox]", step.last? ? 0 : 1 do |check_box|
              checked = checked_steps.include?(step)
              assert_equal checked, !check_box.first.attributes['checked'].nil?,
                "Expected step #{step.name} to be #{checked ? '' : 'un'}checked"
            end
          end
        end
      end
    end
  end
  
  def assert_options(values, names, selected)
    assert_select 'option' do |options|
      options.each do |option|
        expected_value = values.shift
        actual_value = option.attributes['value']
        cur_selected = selected.include?(expected_value)
        
        assert_equal expected_value.to_s, actual_value
        assert_equal names.shift.to_s, option.children.map{ |child| child.to_s }.join
        assert_equal cur_selected, !option.attributes['selected'].nil?,
          "Excepted option #{expected_value} (#{names.first}) to be #{cur_selected ? '' : 'un'}selected"
      end
    end
  end
  
end
