class VotesController < ApplicationController
  before_filter :get_state
  before_filter :get_vote

  def get_vote
    @vote = Vote.find(params[:id], :include => [:bill])
    @vote || resource_not_found
  end  
end
