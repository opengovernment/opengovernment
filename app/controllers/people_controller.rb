class PeopleController < ApplicationController
  before_filter :find_person, :except => [:index, :upper, :lower]
  before_filter :setup_sort, :only => [:index, :upper, :lower]
  before_filter :get_state

  # /states/texas/people
  def index
    @chamber = @state.upper_chamber
    @current_tab = :upper

    if poeple_in_chamber(@sort)
      @people = @facets.for(:chamber_id => @chamber.id)
    else
      @people = []
    end
  end

  def upper
    @chamber = @state.upper_chamber
    @current_tab = :upper
    poeple_in_chamber(params[:sort])
    render :template => 'people/index'
  end

  def lower
    @chamber = @state.lower_chamber
    @current_tab = :lower
    poeple_in_chamber(params[:sort])
    render :template => 'people/index'
  end

  def votes
    @roll_calls = RollCall.paginate(:conditions => {:person_id => @person.id}, :include => {:vote => :bill}, :order => "votes.date desc", :page => params[:page])
  end

  def sponsored_bills
    @sponsorships = BillSponsorship.find_all_by_sponsor_id(@person.id, :include => [:bill]).paginate(:page => params[:page])
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
  
  private

  def poeple_in_chamber(sort)
    # This sets up variables for the view

    @order = case sort
    when 'last_name'
      'last_name asc'
    when 'district'
      'district_order asc'
    when 'citations'
      'citations_count desc'
    else
      'last_name asc'
    end

    begin
      @facets = Person.facets :with => { :chamber_id => @chamber.id }, :order => @order, :per_page => 1000, :select => "people.*, current_district_name_for(people.id) as district_name"
    rescue Riddle::ConnectionError
      flash[:error] = %q{Sorry, we can't look people up at the moment. We'll fix the problem shortly.}
      return nil
    end
  end
  
  def setup_sort
    @sort = params[:sort] || 'name'

    @sorts = {:name => 'Name',
      :district => 'District',
      :citations => 'Public Interest'}
  end

end
