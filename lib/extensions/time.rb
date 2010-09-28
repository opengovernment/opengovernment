class Time
  def to_html
    self.to_s(:timetag).html_safe
  end

  def beginning_of_hour
    self.change(:min => 0)
  end
end
