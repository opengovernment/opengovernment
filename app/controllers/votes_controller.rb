class VotesController < ApplicationController
  before_filter :get_state
  before_filter :find_person, :only => [:index]

  def show
    @vote = Vote.find(params[:id], :include => {:roll_calls => :person})
  end

  protected
  def find_person
    @person = Person.find(params[:person_id])
    @person || resource_not_found
  end
end
