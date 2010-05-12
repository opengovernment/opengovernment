class PeopleController < ApplicationController
  before_filter :find_person, :except => [:index]

  # /states/texas/people
  def index
    if params[:state_id]
      @state = State.find_by_slug(params[:state_id])
      @state || resource_not_found
    end

    # TODO: The order by legislatures.id relies on congress being id = 1
    # that's fragile; later on we should have a "scope" for legislatures perhaps:
    # federal, state, county, municipal, etc.
    @people = Person.find(:all,
      :include => {:roles => [:district, {:chamber => :legislature}]},
      :conditions => ["(current_date between roles.start_date and roles.end_date) and (roles.district_id in (select id from districts where state_id = ?) or roles.state_id = ?)", @state.id, @state.id],
      :order => "legislatures.id, chambers.type desc, districts.census_sld")
  end

  def sponsored_bills
    @sponsorships = Sponsorship.find_all_by_sponsor_id(@person.id, :include => [:bill])
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
