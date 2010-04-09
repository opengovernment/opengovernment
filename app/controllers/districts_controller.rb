class DistrictsController < ApplicationController

  def search
    if @districts = District.find_by_address(params[:q])
      @point = @districts[0]
      @districts = @districts[1]
    end
  end

end
