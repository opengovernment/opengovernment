class PeopleController < SubdomainController
  before_filter :find_person, :except => [:index, :search]
  respond_to :html, :json, :only => [:index, :votes]

  # /states/texas/people
  def index
    # Setup sort.
    @sort = params[:sort] || 'name'

    # check our MongoMapper connection
    if @sort == 'views' && !MongoMapper.connected?
      @sort = 'name'
    end

    @sorts = ActiveSupport::OrderedHash.new
    @sorts[:name] = 'Name'
    @sorts[:district] = 'District'
    @sorts[:views] = 'Most Viewed'
    @sorts[:mentions] = 'Most In The News'

    # Choose chamber
    if params[:chamber] && params[:chamber] == 'lower'
        @chamber = @state.lower_chamber
        @current_tab = :lower
    else
      @chamber = @state.upper_chamber
      @current_tab = :upper
    end

    @people =
      case @sort
        when 'views'
          Person.select("people.*, current_district_name_for(people.id) as district_name, current_party_for(people.id) as party").most_viewed(:subdomain => request.subdomain, :limit => 10)
        else
          people_by_facets
      end

    respond_with(@people)
  end

  def votes
    @roll_calls = RollCall.where(:person_id => @person.id).includes(:vote => :bill).order("votes.date desc").page(params[:page])
    respond_with(@roll_calls)
  end

  def sponsored_bills
    @sponsorships = BillSponsorship.where(:sponsor_id => @person.id).includes(:bill).page(params[:page])
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
        # The to_a is an odd fix for a Rails (bug? feature?) where 
        # grouped scopes like this one return an OrderedHash of groupings for .size and .count
        # unless converted.
        @rating_categories = Category.aggregates_for_person(@person).to_a
        @latest_votes = @person.votes.latest
        @latest_roll_calls = @person.roll_calls.find_all_by_vote_id(@latest_votes)
        @industries = Industry.aggregates_for_person(@person).order('amount desc').limit(5)
        @contributions = @person.contributions.includes(:state).limit(3)
      end
      format.json do
        render(:json => @person)
      end
    end
  end

  def money_trail
    @industries = Industry.aggregates_for_person(@person).order('amount desc').limit(50)
    @contributions = @person.contributions.includes(:state).limit(20)
  end

  def contact
    render :layout => 'popup'
  end

  def search
    # Search for a person to contact. Right now available via a bill page--
    # eg. contact my senator.
    @point = GeoKit::Geocoders::MultiGeocoder.geocode(params[:q])

    if @point
      @state = State.find_by_abbrev(@point.state)

      if params[:chamber_id]
        @chamber = Chamber.find(params[:chamber_id])
        @people = @chamber.current_legislators_by_point(@point)
      end
    end

    render :layout => 'popup'
  end

  def ratings
    if params[:category_id]
      resource_not_found unless @category = Category.find(params[:category_id])
      @ratings = Rating.includes(:special_interest_group).where(:"special_interest_groups.category_id" => @category.id, :person_id => @person.id)
    else
      # The to_a is an odd fix for a Rails (bug? feature?) where 
      # grouped scopes like this one return an OrderedHash of groupings for .size and .count
      # unless converted.
      @rating_categories = Category.aggregates_for_person(@person).to_a
    end
  end


  def news
    @mentions = @person.mentions
    @google_news_mentions = @person.google_news_mentions
    @google_blog_mentions = @person.google_blog_mentions

    respond_to do |format|
      format.html
      format.json { render :json => @mentions }
    end
  end

  protected
  def find_person
    @person = Person.where(:id => params[:id]).select("people.*, current_district_name_for(people.id) as district_name, current_party_for(people.id) as party").first
    @person || resource_not_found
  end

  private
  def people_by_facets
    if people_in_chamber
      @facets.for(:chamber_ids => @chamber.id, :session_ids => current_session.primary_id)
    else
      []
    end
  end

  def people_in_chamber
    # This sets up variables for the view

    @order = case @sort
      when 'district'
        'district_order asc'
      when 'mentions'
        'mentions_count desc'
      else
        'last_name asc'
      end

    begin
      # TODO: This is less than ideal. We're calling some stored procedures here because
      # we don't have a better way (like outer joining to the current roles view).
      @facets = Person.facets :with => {:chamber_ids => @chamber.id, :session_ids => current_session.primary_id}, :order => @order, :per_page => 1000, :select => "people.*, current_district_name_for(people.id) as district_name, current_party_for(people.id) as party"
    rescue Riddle::ConnectionError
      flash[:error] = %q{Sorry, we can't look people up at the moment. We'll fix the problem shortly.}
      return nil
    end
  end

end
