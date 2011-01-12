class VotesController < SubdomainController
  before_filter :get_state_and_session
  before_filter :get_vote

  def get_vote
    @vote = Vote.find(params[:id], :include => [:bill])
    @vote || resource_not_found
  end  
end
