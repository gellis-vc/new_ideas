require File.dirname(__FILE__) + '/../test_helper'

class AdminCommentTest < Test::Unit::TestCase
  scenario :basic
  
  def test_text_required
    test_field_error AdminComment, :text, nil, {}
    test_field_error AdminComment, :text, '', {}
  end
  
  def test_author_required
    test_field_error AdminComment, :author, nil, {}
  end
  
  def test_idea_required
    test_field_error AdminComment, :idea, nil, {}
  end
end
