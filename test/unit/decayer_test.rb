require File.dirname(__FILE__) + '/../test_helper'

class DecayerTest < Test::Unit::TestCase
  scenario :basic
  
  def setup
    @config = {
      :half_life => {
        :idea_rating => 60.days,
        :user_contribution_points => 40.days
      }
    }
  end
  
  def test_idea_rating_decay
    @walruses_in_stores.update_attributes!(:rating => 60, :decayed_at => 120.days.ago)
    Decayer.run_all(@config)
    @walruses_in_stores.reload
    assert_in_delta 15, @walruses_in_stores.rating, 0.5
  end
  
  def test_idea_rating_does_not_decay_when_recently_updated
    @walruses_in_stores.update_attributes!(:rating => 60, :decayed_at => 30.minutes.ago)
    Decayer.run_all(@config)
    @walruses_in_stores.reload
    assert_equal 60, @walruses_in_stores.rating
  end
  
  def test_user_points_decay
    @aaron.contribution_points = 100
    @aaron.decayed_at = 20.days.ago
    @aaron.save!
    Decayer.run_all(@config)
    @aaron.reload
    assert_in_delta 70.71, @aaron.contribution_points, 0.5
  end
  
  def test_user_points_do_not_decay_when_recently_updated
    @aaron.contribution_points = 100
    @aaron.decayed_at = 20.minutes.ago
    @aaron.save!
    Decayer.run_all(@config)
    @aaron.reload
    assert_equal 100, @aaron.contribution_points
  end
  
  def test_handle_decayed_at_nil
    @walruses_in_stores.decayed_at = nil
    @walruses_in_stores.created_at = 60.days.ago
    @walruses_in_stores.rating = 100
    @walruses_in_stores.save!
    Decayer.run_all(@config)
    @walruses_in_stores.reload
    assert_not_nil @walruses_in_stores.decayed_at
    assert_in_delta 50, @walruses_in_stores.rating, 0.5
  end
  
  # TODO: Test multiple batches, MAX_RUNS exceeded
  
end
