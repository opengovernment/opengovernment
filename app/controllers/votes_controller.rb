class VotesController < ApplicationController
  before_filter :get_state

  def show
    @vote = Vote.find(params[:id], :include => {:roll_calls => :person})
    @vote || resource_not_found
  end
  
  def index
    @person = Person.find(params[:person_id])
    @person || resource_not_found
    @roll_calls = RollCall.paginate(:conditions => {:person_id => @person.id}, :include => {:vote => :bill}, :order => "votes.date desc", :page => params[:page])
  end

end
