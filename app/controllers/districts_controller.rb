class DistrictsController < ApplicationController
  def search
    @point = GeoKit::Geocoders::MultiGeocoder.geocode(params[:q])

    if @point
      @state = State.find_by_abbrev(@point.state)

      if @state && @state.supported?
        return
      else
        render :template => "shared/unsupported"
      end
    end
  end
end
