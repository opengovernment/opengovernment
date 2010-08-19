class VotesController < ApplicationController
  before_filter :get_state
  before_filter :get_vote
  add_breadcrumb "Bills", :bills_path, :class => 'bills'

  def show
    add_breadcrumb "#{@vote.bill.bill_number}", bill_path(@vote.bill.session, @vote.bill), :class => "vote #{@vote.outcome_class}"
  end

  def get_vote
    @vote = Vote.find(params[:id], :include => [:bill])
    @vote || resource_not_found
  end  
end
