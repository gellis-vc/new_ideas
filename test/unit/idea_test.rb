require File.dirname(__FILE__) + '/../test_helper'

class IdeaTest < Test::Unit::TestCase
  
  scenario :basic
  
  def test_required_fields
    test_idea_field_error :title, nil
    test_idea_field_error :title, ''
    test_idea_field_error :description, nil
    test_idea_field_error :description, ''
    test_idea_field_error :status, '' 
    test_idea_field_error :status, nil 
    test_idea_field_error :status, 'fubar' 
  end
  
  def test_max_length
    test_idea_field_error :title, (1..100).to_a.join
  end
  
  def test_inventor_relationship
    assert_equal @quentin, @walruses_in_stores.inventor
    assert_equal_unordered [@walruses_in_stores, @spam_idea], @quentin.ideas
    assert_equal [@inactive_user_idea], @aaron.ideas
  end
  
  def test_vote
    assert_equal 0, @walruses_in_stores.rating
    @walruses_in_stores.add_vote!(@sally)
    assert_equal 1, @walruses_in_stores.rating
    @walruses_in_stores.add_vote!(@sally)
    assert_equal 1, @walruses_in_stores.rating
    @walruses_in_stores.add_vote!(@quentin)
    assert_equal 2, @walruses_in_stores.rating
    
    @sally.reload
    assert_equal 101, @sally.contribution_points
    @quentin.reload
    assert_equal 200, @quentin.contribution_points # quentin does NOT get points for voting for his own idea
    assert_equal_unordered [@sally, @quentin], @walruses_in_stores.voters
  end
  
  def test_vote_not_counted_until_user_verified
    @walruses_in_stores.add_vote!(@aaron)
    @walruses_in_stores.reload
    assert_equal 0, @walruses_in_stores.rating
    
    @aaron.activate!
    @walruses_in_stores.reload
    assert_equal 1, @walruses_in_stores.rating
  end

  def test_flag_as_inappropriate
    assert_equal 0, @walruses_in_stores.inappropriate_flags
    @walruses_in_stores.flag_as_inappropriate!
    assert_equal 1, @walruses_in_stores.inappropriate_flags
  end
  
  def test_comment_relationship
    assert_equal_unordered [@walrus_comment_spam, @walrus_comment1, @walrus_comment2, @hidden_comment], @walruses_in_stores.comments
    assert_equal_unordered [@walrus_comment2], @walruses_in_stores.comments.visible
  end
  
  def test_duplicate_relationship
    assert_equal_unordered [@duplicate_idea], @walruses_in_stores.duplicates
    assert_equal_unordered [@duplicate_idea], @walruses_in_stores.duplicates.visible
    
    @duplicate_idea.update_attributes!(:hidden => true)
    assert_equal_unordered [@duplicate_idea], @walruses_in_stores.duplicates
    assert_equal_unordered [], @walruses_in_stores.duplicates.visible
    
    @duplicate_idea.update_attributes!(:hidden => false)
    @sally.suspend!
    assert_equal_unordered [@duplicate_idea], @walruses_in_stores.duplicates
    assert_equal_unordered [], @walruses_in_stores.duplicates.visible
  end
  
  def test_score_for_create
    @sally.ideas.create!(:title => 'foo', :description => 'bar')
    @sally.reload
    assert_equal 110, @sally.contribution_points
  end
  
  def test_life_cycle_relationship
    assert_equal @good_idea_dance, @walruses_in_stores.life_cycle_step
    assert_equal nil, @barbershop_discount.life_cycle_step
  end
  
  def test_duplicate_linking
    assert_equal @walruses_in_stores, @duplicate_idea.duplicate_of
    assert_equal [@duplicate_idea], @walruses_in_stores.duplicates
  end
  
  def test_comment_count_does_not_include_hidden_comments
    assert_equal 1, @walruses_in_stores.comment_count
  end
  
  def test_populate_comment_counts
    Idea.populate_comment_counts [@walruses_in_stores, @barbershop_discount]
    assert_equal 1, @walruses_in_stores.comment_count
    assert_equal 0, @barbershop_discount.comment_count
  end
  
  def test_closed
    my_idea = Idea.new(:title=>"My Idea", :description=>"Foo", :current=>@closed_current)
    my_idea.stubs(:current).returns(@closed_current)
    my_idea.stubs(:current_id).returns(@closed_current.id)
    assert_equal true, my_idea.closed?
  end
  
  # Should return closed when the idea's current is expired 
  # even if the current's "closed" attribute hasn't been set to true
  def test_closed_when_current_is_expired
    my_idea = Idea.new(:title=>"My Idea", :description=>"Foo", :current=>@expired_current)
    assert_equal false, @expired_current.closed?
    my_idea.stubs(:current).returns(@expired_current)
    assert_equal true, my_idea.closed?
  end
  
  def test_validate_current_not_closed_when_creating
    my_idea = Idea.new(:title=>"My Idea", :description=>"Foo", :current_id=>@closed_current.id)
    assert_not_equal @default_current, my_idea.current
    assert_equal false, my_idea.save
    assert_equal "You are trying to add/update an idea in a closed current.  That's not allowed.", my_idea.errors[:base]
  end
  
  def test_validate_current_not_closed_when_updating
    #mock_current = mock("current", :closed? => true, :valid? => true)
    @tranquilizer_guns.stubs(:current).returns(@closed_current)
    assert_equal false, @tranquilizer_guns.save
    assert_equal "You are trying to add/update an idea in a closed current.  That's not allowed.", @tranquilizer_guns.errors[:base]
  end
  
  def test_editing_expired
    idea = Idea.create(:title=>"My Idea", :description=>"Foo", :current => @default_current)
    assert !idea.editing_expired?
    idea.update_attribute(:created_at, 15.minutes.ago)
    assert idea.editing_expired?
  end
  
  def test_editable_by
    idea = Idea.create(:title=>"My Idea", :description=>"Foo", :current => @default_current, :inventor => @quentin)
    assert idea.editable_by?(@quentin)
    idea.update_attribute(:created_at, 15.minutes.ago)
    assert !idea.editable_by?(idea.inventor)
  end
  
  def test_duplicate_tags
    idea = Idea.create!(
      :title=>"My Idea", :description=>"Foo", :current => @default_current,
      :inventor => @quentin, :tags => [@walrus_tag, @crazy_tag, @walrus_tag, @crazy_tag, @crazy_tag])
    idea.reload
    assert_equal 2, idea.tags.count
  end
  
private

  def test_idea_field_error(field, value)
    test_field_error Idea, field, value,
      :inventor => @quentin,
      :title => 'foo',
      :description => 'bar'
  end
  
end
