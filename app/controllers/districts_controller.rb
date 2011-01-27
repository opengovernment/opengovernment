class DistrictsController < ApplicationController
  def search
    @point = GeoKit::Geocoders::MultiGeocoder.geocode(params[:q])

    if @point
      @state = State.find_by_abbrev(@point.state)
      @available_sessions = (@state ?
        @state.sessions.major.complete.order("start_year desc") :
        [])
      if @state && @state.supported?
        return
      elsif @state
        render :template => 'states/unsupported', :layout => 'home'
      else
        flash[:error] = "Sorry, we can't find that address."
        begin
          redirect_to :back
        rescue RedirectBackError
          redirect_to(root_url)
        end
      end
    end
  end
end
