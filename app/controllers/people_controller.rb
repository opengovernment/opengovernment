class PeopleController < ApplicationController
  before_filter :find_person, :except => [:index]

  # /states/texas/people
  def index
    if params[:state_id]
      @state = State.find_by_slug(params[:state_id])
      @state || resource_not_found
    end

  end

  # /people/1
  def show

  end

  protected
  def find_person
    @person = Person.find(params[:id])
    @person || resource_not_found
  end
end
