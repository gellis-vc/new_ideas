module Rfc2119Helper
  def rfc2119(word)
    "<span class='rfc2119'>#{word}</span>"
  end

  def should
    rfc2119 'should'
  end

  def may
    rfc2119 'may'
  end

  def must
    rfc2119 'must'
  end

  def should_not
    rfc2119 'should not'
  end

  def must_not
    rfc2119 'must not'
  end
end