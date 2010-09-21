class MoneyTrailsController < ApplicationController
  before_filter :get_state
  before_filter :get_industry, :only => [:show]

  def index
    # We call .all here so we can execute the query now, due to a 
    # Rails bug with .count and .size
    @sectors = Sector.aggregates_for_state(@state.id).all
  end
  
  def show
    @contributions = @industry.contributions.for_state(@state.id).grouped_by_name.limit(20).all
  end

  protected
  def get_industry
    @industry = Industry.find(params[:id])
  end
end
