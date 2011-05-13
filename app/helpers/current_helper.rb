module CurrentHelper
  
  def display_invitees
    @current.has_invitees.inspect
  end
  
end
