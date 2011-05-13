class IdeaObserver < ActiveRecord::Observer
  
  def after_save(idea)
    return unless idea.life_cycle_step_id_changed?
    return unless idea.life_cycle_step
    idea.life_cycle_step.admins.each do |admin|
      next unless admin.notify_on_state?
      UserMailer.deliver_life_cycle_notification(admin, idea.life_cycle_step)
    end
  end
  
end
