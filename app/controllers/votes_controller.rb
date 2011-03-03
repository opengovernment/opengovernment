class VotesController < SubdomainController
  before_filter :get_state_and_session
  before_filter :get_vote

  def get_vote
    begin
      @vote = Vote.find(params[:id], :include => [:bill])
    rescue ActiveRecord::RecordNotFound
      @vote = Vote.find_by_openstates_id(params[:id], :include => [:bill])
    end

    @vote || resource_not_found
  end  
end
