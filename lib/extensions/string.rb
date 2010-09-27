class String
  def possessive
    self + (self[-1,1] == 's' ? %q{'} : %q{'s})
  end
  
  # For a string like "1/2", returns a float 0.5
  def to_frac
    numerator, denominator = split('/').map(&:to_f)
    denominator ||= 1
    numerator/denominator
  end
  
end
