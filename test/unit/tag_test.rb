require File.dirname(__FILE__) + '/../test_helper'

class TagTest < Test::Unit::TestCase
  scenario :basic
  
  def test_name_required
    test_field_error Tag, :name, nil, {}
    test_field_error Tag, :name, '', {}
  end
  
  def test_name_must_be_unique
    test_field_error Tag, :name, 'crazy ideas', {}
  end
  
  def test_idea_relationship
    assert_equal_unordered [@walruses_in_stores], @walrus_tag.ideas
    assert_equal_unordered [@barbershop_discount, @walruses_in_stores], @crazy_tag.ideas
    assert_equal_unordered [@walrus_tag, @crazy_tag], @walruses_in_stores.tags
    assert_equal_unordered [@crazy_tag], @barbershop_discount.tags
  end
  
  def test_create_by_name
    old_count = Tag.count
    new_tag = Tag.find_or_create_by_name('linGUIne')
    assert_equal 'linguine', new_tag.name
    assert_equal old_count+1, Tag.count
  end
  
  def test_find_by_name
    old_count = Tag.count
    found_tag = Tag.find_or_create_by_name('CRazy   iDeAs')
    assert_equal @crazy_tag, found_tag
    assert_equal old_count, Tag.count
  end
  
  def test_from_string
    tags = Tag.from_string("   wALruSSy ,   new Tag,crazy  ideas ")
    newtag = Tag.find_by_name('new tag')
    assert_equal [@walrus_tag, newtag, @crazy_tag], tags
    assert newtag
  end
  
  def test_find_with_idea_counts
    tags = Tag.find_with_idea_counts(:order => 'idea_count desc')
    assert_equal [@crazy_tag, @walrus_tag], tags
    assert_equal 2, tags[0].idea_count.to_i
    assert_equal 1, tags[1].idea_count.to_i
  end
  
  def test_find_with_idea_counts_ignores_hidden_idea_tag
    @walruses_in_stores.hidden = true
    @walruses_in_stores.save!
    tags = Tag.find_with_idea_counts
    assert_equal [@crazy_tag], tags
    assert_equal 1, tags[0].idea_count.to_i
  end
  
  def test_find_with_idea_counts_ignores_unverified_user_tag
    @sally.suspend!
    tags = Tag.find_with_idea_counts(:select=>'tags.name, tags.id, count(*) as idea_count', :order => 'tags.name desc', :group => 'tags.name, tags.id')
    assert_equal [@walrus_tag, @crazy_tag], tags
    assert_equal 1, tags[0].idea_count.to_i
    assert_equal 1, tags[1].idea_count.to_i
  end

end
