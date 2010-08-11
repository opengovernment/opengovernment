class PeopleController < ApplicationController
  before_filter :find_person, :except => [:index]
  before_filter :get_state, :only => [:index]
  add_breadcrumb "people", :people_path, :class => 'people'

  # /states/texas/people
  def index
    # TODO: The order by legislatures.id relies on congress being id = 1
    # that's fragile; later on we should have a "scope" for legislatures perhaps:
    # federal, state, county, municipal, etc.
    @people = Person.find(:all,
      :include => {:roles => [:district, {:chamber => :legislature}]},
      :conditions => ["(current_date between roles.start_date and roles.end_date) and (roles.district_id in (select id from districts where state_id = ?) or roles.state_id = ?)", @state.id, @state.id],
      :order => "legislatures.id, chambers.type desc, districts.census_sld")
  end

  def votes
    @roll_calls = RollCall.paginate(:conditions => {:person_id => @person.id}, :include => {:vote => :bill}, :order => "votes.date desc", :page => params[:page])
  end

  def sponsored_bills
    @sponsorships = Sponsorship.find_all_by_sponsor_id(@person.id, :include => [:bill]).paginate(:page => params[:page])
  end

  # /people/1
  def show
    add_breadcrumb @person.full_name, person_path(@person), :class => 'person'

    @latest_votes = @person.votes.latest
    @latest_roll_calls = @person.roll_calls.find_all_by_vote_id(@latest_votes)
  end

  protected
  def find_person
    @person = Person.find(params[:id])
    @person || resource_not_found
  end
  
end
