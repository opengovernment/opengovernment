class PeopleController < ApplicationController
  before_filter :find_person
  
  def show

  end

  protected
  def find_person
    @person = Person.find(params[:id])
    @person || resource_not_found
  end
end
