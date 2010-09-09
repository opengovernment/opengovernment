class MoneyTrailsController < ApplicationController
  before_filter :get_state

  def show
    @sectors = Sector.all
  end
end
