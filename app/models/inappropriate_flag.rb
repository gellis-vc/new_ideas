module InappropriateFlag
  def flag_as_inappropriate!
    transaction do
      lock!
      self.inappropriate_flags += 1
      save!
    end
  end
end
