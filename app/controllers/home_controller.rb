class HomeController < ApplicationController
  layout 'home'

  DEFAULT_STATE_COLOR = '#DDDDDD'
  SUPPORTED_STATE_COLOR = '#FCFBE6'
  STATE_BORDER_COLOR = '#608BBF'
#  PENDING_STATE_COLOR = '#00FF00'
#  MAP_BG_COLOR = '#EAF7FE'

  # Note, please maintain this aspect ratio
  MAP_WIDTH = 950
  MAP_HEIGHT = 500
  MAP_POST_URL = %q(#{Settings.geoserver_base_url}/wms?
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

      # format.png do
      #    states_map_png = Rails.cache.read("states_map_png")
      #    if states_map_png.nil?
      #      f = "image/png"
      #      w = MAP_WIDTH
      #      h = MAP_HEIGHT
      #      uri = URI.parse(eval('"' + MAP_POST_URL + '"'))
      #      http = Net::HTTP.new(uri.host, uri.port)
      #      http.open_timeout = 15 # in seconds
      #      http.read_timeout = 15 # in seconds
      # 
      #      # The request.
      #      req = Net::HTTP::Get.new(uri.request_uri)
      #      res = http.request(req)
      # 
      #      states_map_png = res.body
      #      Rails.cache.write("states_map_png", states_map_png)
      #      send_data(states_map_png)
      #    end
      #end
    end
  end

  def index
    # Bots don't redirect.
    if !is_megatron?
      # Do they have a preferred location cookie?
      if session[:preferred_location]
        redirect_to(url_for(:subdomain => session[:preferred_location])) and return
      end

      # Send them somewhere via geoip, if possible
      if (sub = Subdomain.from_ip(request.ip)) && State.find_by_slug(sub).try(:supported?)
        redirect_to(url_for(:subdomain => sub)) and return
      end
    end

    @states = State.loadable
  end
  
  def home
    @states = State.loadable

    render :template => 'home/index'
  end
  
  # This is here and not in PersonController because PesonController is subdomained, and we need this
  # available without a subdomain.
  # eg. http://opengovernment.org/people/govtrack/300011
  # Lookup a person by GovTrack ID and redirect to people#show
  def person_from_govtrack_id
    if person = Person.find_by_govtrack_id(params[:govtrack_id])
      redirect_to(person_url(person, :subdomain => State.find(person.state_id).try(:abbrev).try(:downcase))) and return
    else
      resource_not_found
    end
  end

end
