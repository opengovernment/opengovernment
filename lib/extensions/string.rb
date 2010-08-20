class String
  def possessive
    self + (self[-1,1] == 's' ? %q{'} : %q{'s})
  end
end
