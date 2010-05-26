class DistrictsController < ApplicationController
  before_filter :find_district, :except => :search

  # TODO: Remove when public
  skip_before_filter :authenticate, :only => :show

  def search
    @point = GeoKit::Geocoders::MultiGeocoder.geocode(params[:q])

    if @point
      @state = State.find_by_abbrev(@point.state)
      redirect_to state_path(@state) unless @state.nil? || @state.supported?
    end
    
  end

  def show
    respond_to do |format|
      format.html do
        @center = @district.geom.envelope.center
        render :layout => false
      end
      format.kml
    end
  end

  def find_district
    @district = params[:id] ? District.find_by_id(params[:id]) : nil
  end
end
