class HomeController < ApplicationController
  before_filter :authenticate, :only => :index

  DEFAULT_STATE_COLOR = '#DDDDDD'
  SUPPORTED_STATE_COLOR = '#FF0000'
  PENDING_STATE_COLOR = '#00FF00'
  MAP_BG_COLOR = '#EAF7FE'

  # Note, please maintain this aspect ratio
  MAP_WIDTH = 800
  MAP_HEIGHT = 450
  MAP_POST_URL = %q(#{GEOSERVER_BASE_URL}/wms?
    service=WMS
    &request=GetMap
    &version=1.1.1
    &layers=topp:states
    &bbox=-130,24,-66,50
    &transparent=true
    &width=#{w}
    &height=#{h}
    &format=#{f}
    &sld=#{CGI::escape(url_for(:controller => 'home', :action => 'us_map', :format => :xml, :only_path => false))}).gsub(/\n\s+/,'')
    
  def us_map
    respond_to do |format|
      format.xml do
        render(:partial => "states_getmap.xml")
      end

      format.png do
        states_map_png = Rails.cache.read("states_map_png")
        if states_map_png.nil?
          f = "image/png"
          w = MAP_WIDTH
          h = MAP_HEIGHT
          uri = URI.parse(eval('"' + MAP_POST_URL + '"'))
          http = Net::HTTP.new(uri.host, uri.port)
          http.open_timeout = 5 # in seconds
          http.read_timeout = 5 # in seconds

          # The request.
          req = Net::HTTP::Get.new(uri.request_uri)
          res = http.request(req)

          states_map_png = res.body
          Rails.cache.write("states_map_png", states_map_png)
          send_data(states_map_png)
        end
      end
    end
  end

end
