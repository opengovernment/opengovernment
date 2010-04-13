class DistrictsController < ApplicationController
  before_filter :find_district, :except => :search

  def search
    if @districts = District.find_by_address(params[:q])
      @point = @districts[0]
      @districts = @districts[1]
    end
  end

  def show
    @map = GMap.new("map_div")

    @map.control_init(:large_map => true, :map_type => true)

    @map.center_zoom_init([33, -87],6)
    
    render :layout => false
  end

  def show_js

    if @district.nil?
      @message = "#{params[:id]} not in Districts"
    else

      @id = dta.id
      @map = Variable.new("map")
      
      envelope = dta.geom[0].envelope

      @polygons = dta.geom.collect { |poly| GPolygon.from_georuby(poly,"#000000",0,0.0,"#ff0000",0.6) }

      @center = GLatLng.from_georuby(envelope.center)
      @zoom = @map.get_bounds_zoom_level(GLatLngBounds.from_georuby(envelope))

    end
  end

  def find_district
    @district = params[:id] ? District.find_by_id(params[:id]) : nil
  end

end
