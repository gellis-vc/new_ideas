require File.dirname(__FILE__) + '/../test_helper'

class AdminTagTest < Test::Unit::TestCase
  scenario :basic
  
  def test_name_required
    test_field_error AdminTag, :name, nil, {}
    test_field_error AdminTag, :name, '', {}
  end
  
  def test_name_must_be_unique
    test_field_error AdminTag, :name, 'hire this person', {}
  end
  
  def test_name_can_match_user_tag
    AdminTag.create!(:name => @walrus_tag.name)
  end
  
  def test_idea_relationship
    assert_equal_unordered [@barbershop_discount], @hire_this_person_tag.ideas
    assert_equal_unordered [], @walruses_in_stores.admin_tags
    assert_equal_unordered [@hire_this_person_tag], @barbershop_discount.admin_tags
  end
  
  def test_create_by_name
    old_count = AdminTag.count
    new_tag = AdminTag.find_or_create_by_name('linGUIne')
    assert_equal 'linguine', new_tag.name
    assert_equal old_count+1, AdminTag.count
  end
  
  def test_find_by_name
    old_count = AdminTag.count
    found_tag = AdminTag.find_or_create_by_name('Hire this person')
    assert_equal @hire_this_person_tag, found_tag
    assert_equal old_count, AdminTag.count
  end
  
  def test_from_string
    tags = AdminTag.from_string("Hire this person,new Tag")
    newtag = AdminTag.find_by_name('new tag')
    assert_equal [@hire_this_person_tag, newtag], tags
    assert newtag
  end
  
  def test_find_with_idea_counts
    tags = AdminTag.find_with_idea_counts(:order => 'idea_count') 
    assert_equal [@hire_this_person_tag], tags
    assert_equal 1, tags[0].idea_count.to_i
  end

end
