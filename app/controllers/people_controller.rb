class PeopleController < ApplicationController
  before_filter :find_person, :except => [:index]
  before_filter :get_state

  # /states/texas/people
  def index
    @order = case params[:sort]
    when 'last_name'
      'last_name asc'
    when 'district'
      'district_order asc'
    when 'citations'
      'citations_count desc'
    else
      'last_name asc'
    end

  @facets = Person.facets :with => { :chamber_id => @state.chamber_ids }, :order => @order, :per_page => 1000, :select => "people.*, current_district_name_for(people.id) as district_name"
  end

  def votes
    @roll_calls = RollCall.paginate(:conditions => {:person_id => @person.id}, :include => {:vote => :bill}, :order => "votes.date desc", :page => params[:page])
  end

  def sponsored_bills
    @sponsorships = Sponsorship.find_all_by_sponsor_id(@person.id, :include => [:bill]).paginate(:page => params[:page])
  end

  # /people/1
  def show
   respond_to do |format|
     format.js
     format.atom do
       @roll_calls = RollCall.all(:conditions => {:person_id => @person.id}, :include => {:vote => :bill}, :order => "votes.date desc", :limit => 20)
       render :template => 'people/votes'
     end
     format.html do
       @latest_votes = @person.votes.latest
       @latest_roll_calls = @person.roll_calls.find_all_by_vote_id(@latest_votes)
     end
   end
  end

  protected
  def find_person
    @person = Person.find(params[:id])
    @person || resource_not_found
  end
  
end
