class VotesController < ApplicationController
  before_filter :get_state
  
  def show
    @vote = Vote.find(params[:id], :include => [:roll_calls])
  end
end