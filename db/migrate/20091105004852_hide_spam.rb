class HideSpam < ActiveRecord::Migration
  def self.up
    Idea.update_all({ :hidden => true }, { :marked_spam => true })
  end

  def self.down
  end
end
