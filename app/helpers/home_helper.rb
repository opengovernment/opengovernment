module HomeHelper
  DEFAULT_STATE_COLOR = "FFFFFF"
  SUPPORTED_STATE_COLOR = "FF0000"
  PENDING_STATE_COLOR = "00FF00"
  MAP_BG_COLOR = "EAF7FE"

  def us_map_image_tag
    # See http://code.google.com/apis/chart/docs/gallery/map_charts.html#statecodes
    # This should return something like <img src="http://chart.apis.google.com/chart?cht=t&chs=440x220&chd=t:0,100,50,32,60,40,43,12,14,54,98,17,70,76,18,29&chco=FFFFFF,FF0000,FFFF00,00FF00&chld=ALCACOSCUTNMARILNMWIAKIAMDTNNDOH&chtm=usa&chf=bg,s,EAF7FE">
    states = State.supported | State.pending
    chld = states.collect { |s| s.abbrev }.join
    chd = states.collect { |s| s.supported? ? "A" : "9" }
    %Q{<img src="http://chart.apis.google.com/chart?cht=t&chs=440x220&chd=s:#{chd}&chco=#{DEFAULT_STATE_COLOR},#{SUPPORTED_STATE_COLOR},#{PENDING_STATE_COLOR}&chld=#{chld}&chtm=usa&chf=bg,s,#{MAP_BG_COLOR}">}.html_safe!
  end

end
