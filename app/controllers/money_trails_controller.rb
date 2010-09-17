class MoneyTrailsController < ApplicationController
  before_filter :get_state

  def show
    # We call .all here so we can execute the query now, due to a 
    # Rails bug with .count and .size
    @sectors = Sector.contributions_for_state(@state.id).all
  end
end
