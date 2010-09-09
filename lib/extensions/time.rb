class Time
  def to_html
    self.to_s(:timetag).html_safe
  end
end