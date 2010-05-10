class DistrictsController < ApplicationController
  before_filter :find_district, :except => :search

  def search
    @point, @districts = District.find_by_address(params[:q])

    if @point
      @state = State.find_by_abbrev(@point.state)

      @representatives = {}

      @districts.each do |district|
        @representatives[district] = district.current_legislators.first
      end

      @senators = @state.current_senators
    end
  end

  def find_district
    @district = params[:id] ? District.find_by_id(params[:id]) : nil
  end
end
