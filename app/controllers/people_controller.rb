class PeopleController < ApplicationController
  before_filter :find_person, :except => [:index, :upper, :lower]
  before_filter :setup_sort, :only => [:index, :upper, :lower]
  before_filter :get_state

  # /states/texas/people
  def index
    upper
  end

  def upper
    @chamber = @state.upper_chamber
    @current_tab = :upper

    render_people
  end

  def lower
    @chamber = @state.lower_chamber
    @current_tab = :lower

    render_people
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

  def money_trail
    @sectors = Sector.aggregates_for_person(@person).all
    @contributions = Contribution.where(:person_id => @person.id).order('amount desc').includes(:state).limit(20)
  end

  protected
  def find_person
    @person = Person.find(params[:id])
    @person || resource_not_found
  end

  private
  def people_by_facets
    if people_in_chamber
      @facets.for(:chamber_id => @chamber.id)
    else
      []
    end
  end

  def people_in_chamber
    # This sets up variables for the view

    @order = case @sort
      when 'district'
        'district_order asc'
      when 'citations'
        'citations_count desc'
      else
        'last_name asc'
      end

    begin
      # TODO: This is less than ideal. We're calling some stored procedures here because
      # we don't have a better way (like outer joining to the current roles view).
      @facets = Person.facets :with => {:chamber_id => @chamber.id}, :order => @order, :per_page => 1000, :select => "people.*, current_district_name_for(people.id) as district_name, current_party_for(people.id) as party"
    rescue Riddle::ConnectionError
      flash[:error] = %q{Sorry, we can't look people up at the moment. We'll fix the problem shortly.}
      return nil
    end
  end

  def setup_sort
    @sort = params[:sort] || 'name'

    # check our MongoMapper connection
    if @sort == 'views' && !MongoMapper.connected?
      @sort = 'name'
    end

    @sorts = ActiveSupport::OrderedHash.new
    @sorts[:name] = 'Name'
    @sorts[:district] = 'District'
    @sorts[:views] = 'Most Viewed'
    @sorts[:citations] = 'Most In The News'
  end

  def render_people
    @people =
      case @sort
        when 'views'
          # This is gnarly. We have to generate a case statement for PostgreSQL in order to
          # get the people out in page view order. AND we need an SQL in clause for the people.

          # It does result in only one SQL call, though.
          # Good thing this is only ever limited to 10 or 20 people.

          countable_ids = Page.most_viewed('Person').collect(&:countable_id)

          Person.select("people.*, current_district_name_for(people.id) as district_name, current_party_for(people.id) as party").find_in_explicit_order('people.id', countable_ids)
        else
          people_by_facets
      end

    render :template => 'people/index'
  end
end
