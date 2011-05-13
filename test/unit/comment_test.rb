require File.dirname(__FILE__) + '/../test_helper'

class CommentTest < Test::Unit::TestCase
  
  scenario :basic
  should_have_db_column :ip
  should_have_db_column :user_agent
  should_validate_presence_of :ip
  should_validate_presence_of :user_agent
  
  context "when check_rakismet returns false" do
    setup do
      @comment = @walrus_comment_spam.clone
      @comment.expects(:spam?).returns(true)
      @comment.marked_spam=false
      assert !@comment.marked_spam?
    end
    should "be marked spam" do
      Rakismet::KEY='foo'
      @comment.save
      @comment.reload
      assert @comment.marked_spam?
    end
  end
  
  context "an instance" do
    setup do
      @comment = Comment.create(:text=>'foo', :author => @sally, :user_agent => 'fubar') 
    end
    should "respond to comment_type with comment" do
      assert_equal 'comment', @comment.comment_type
    end
    should "interface to akismet" do
      assert @comment.respond_to?(:spam?)
      assert @comment.respond_to?(:akismet_response)
    end
  end
  
  
  context "a comment on an idea from a user with notifications on" do
    setup do
      @walruses_in_stores.inventor.update_attribute(:notify_on_comments, true)
      @comment = @walruses_in_stores.comments.create!(:text=>"Foo", :ip=>'127.0.0.1', :user_agent=>'foobar', :author => @quentin)
    end

    should "send out e-mail notification" do
      assert_sent_email do |email|
        email.subject =~ /Your idea has received a comment/
      end
    end
  end
  
  

  def test_required_fields
    test_comment_field_error(:author, nil)
    test_comment_field_error(:idea, nil)
    test_comment_field_error(:text, nil)
    test_comment_field_error(:text, '')
  end

  def test_flag_as_inappropriate
    assert_equal 0, @walrus_comment2.inappropriate_flags
    @walrus_comment2.flag_as_inappropriate!
    assert_equal 1, @walrus_comment2.inappropriate_flags
  end
  
  def test_score_for_create
    @walruses_in_stores.comments.create!(:text => 'foo', :author => @sally, :ip=>'127.0.0.1', :user_agent=>'foobar')
    @sally.reload
    assert_equal 102, @sally.contribution_points
  end

  def test_validate_current_not_closed_when_adding_comment
    my_comment = Comment.new(:idea=>@tranquilizer_guns, :text=>'foo', :author => @sally, :user_agent => 'fubar', :ip=>'127.0.0.1') 
    @tranquilizer_guns.stubs(:closed?).returns(true)    
    assert_equal false, my_comment.save
    assert_equal "You are trying to comment on an idea within a closed current.  That's not allowed.", my_comment.errors[:base]
  end
  
  def test_editing_expired
    comment = @walruses_in_stores.comments.create!(:text=>"Foo", :ip=>'127.0.0.1', :user_agent=>'foobar', :author => @quentin)
    assert !comment.editing_expired?
    comment.update_attribute(:created_at, 15.minutes.ago)
    assert comment.editing_expired?
  end
  
  def test_editable_by
    comment = @walruses_in_stores.comments.create!(:text=>"Foo", :ip=>'127.0.0.1', :user_agent=>'foobar', :author => @quentin)
    assert comment.editable_by?(@quentin)
    comment.update_attribute(:created_at, 15.minutes.ago)
    assert !comment.editable_by?(comment.author)
  end
  
private

  def test_comment_field_error(field, value)
    test_field_error Comment, field, value,
      :author => @quentin,
      :idea => @walruses_in_stores,
      :text => 'testy'
  end

end
