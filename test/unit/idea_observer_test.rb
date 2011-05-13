require File.dirname(__FILE__) + '/../test_helper'

class IdeaObserverTest < ActiveSupport::TestCase
  
  scenario :basic
  
  context "an idea entering a life cycle step with an admin with notifications on" do
    setup do
      @bad_idea_mock.admins.first.update_attribute(:notify_on_state, true)
      @walruses_in_stores.update_attributes(:life_cycle_step_id => @bad_idea_mock.id)
    end

    should "send out e-mail notification" do
      assert_sent_email do |email|
        email.subject =~ /New idea requiring attention/
      end
    end
  end
end
