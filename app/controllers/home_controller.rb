class HomeController < ApplicationController
  DEFAULT_STATE_COLOR = '#DDDDDD'
  SUPPORTED_STATE_COLOR = '#FF0000'
  PENDING_STATE_COLOR = '#00FF00'
  MAP_BG_COLOR = '#EAF7FE'

  # Note, please maintain this aspect ratio
  MAP_WIDTH = 550
  MAP_HEIGHT = 250
  MAP_POST_URL = %q(http://localhost:8080/geoserver/wms?
    service=WMS
    &request=GetMap
    &version=1.1.1
    &layers=topp:states
    &bbox=-130,24,-66,50
    &width=#{w}
    &height=#{h}
    &format=#{f}
    &sld=#{CGI::escape('http://localhost:3000/us_map.xml')}).gsub(/\n\s+/,'')
  
  def us_map
    respond_to do |format|
      format.xml do
        render(:partial => "states_getmap.xml")
      end

      format.html do
        Rails.cache.delete("states_map_tag")

        states_map_tag = Rails.cache.read("states_map_tag")
        if states_map_tag.nil?
          f = "text/html"
          w = HomeController::MAP_WIDTH
          h = HomeController::MAP_HEIGHT
          http = EM::HttpRequest.new(eval('"' + HomeController::MAP_POST_URL + '"')).get
          states_map_tag = http.response
          Rails.cache.write("states_map_tag", states_map_tag)
        end

        render(:text => %Q{<img src="/us_map.png" width="#{HomeController::MAP_WIDTH}" height="#{HomeController::MAP_HEIGHT}" alt="USA" usemap="#states" />} + states_map_tag)
      end

      format.png do
        Rails.cache.delete("states_map_png")
        states_map_png = Rails.cache.read("states_map_png")
        if states_map_png.nil?
          f = "image/png"
          w = MAP_WIDTH
          h = MAP_HEIGHT
          http = EM::HttpRequest.new(eval('"' + MAP_POST_URL + '"')).get
          states_map_png = http.response
          Rails.cache.write("states_map_png", states_map_png)
        end
        send_data(states_map_png)
      end
    end
    
  end

  def index
    # going meta, query yourself, on the same thin server!
    http = EM::HttpRequest.new("http://www.google.com/").get
    render :text => http.response
  end

end
