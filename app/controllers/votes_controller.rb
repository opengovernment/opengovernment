class VotesController < ApplicationController
  before_filter :get_state

  def show
    @vote = Vote.find(params[:id], :include => {:roll_calls => :person})
    @vote || resource_not_found
  end
  
  def index
    @person = Person.find(params[:person_id], :include => {:roll_calls => {:vote => :bill}}, :order => "votes.date desc")
    @person || resource_not_found
  end

end
