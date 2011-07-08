class BillsController < SubdomainController
  before_filter :redirect_if_subsession, :only => [:index, :upper, :lower]
  before_filter :get_bill, :except => [:index, :upper, :lower, :search]
  before_filter :setup_sort, :only => [:index, :upper, :lower]
  respond_to :html, :only => [:index, :show]
  respond_to :json, :xml, :only => [:index, :show, :search]

  def index
    expires_in 30.minutes
    
    @bills = scope_bills(Bill.for_session_including_children(@session.primary_id))
    @current_tab = :all

    respond_with(@bills)
  end

  def search
    if @bills = @state.bills.find_by_slug(params[:q])
      respond_with(@bills)
    else
      resource_not_found
    end
  end

  def upper
    expires_in 30.minutes

    @bills = scope_bills(Bill.for_session_including_children(@session).in_chamber(@state.legislature.upper_chamber))
    @current_tab = :upper
    render :template => 'bills/index'
  end
  
  def lower
    expires_in 30.minutes

    @bills = scope_bills(Bill.for_session_including_children(@session).in_chamber(@state.legislature.lower_chamber))
    @current_tab = :lower
    render :template => 'bills/index'
  end

  def show
    expires_in 30.minutes

    @sponsors = @bill.sponsorships.includes(:sponsor).order("people.last_name, bill_sponsorships.sponsor_name")
    @sponsor_count = @bill.sponsorships.count
    @votes = @bill.votes
    @actions = @bill.actions

    respond_with(@bill)
  end

  def sponsors
    @sponsors = @bill.sponsorships.includes(:sponsor).order("people.last_name, bill_sponsorships.sponsor_name")
  end

  def documents
    @documents = @bill.all_documents.order("document_type, created_at desc").page(params[:page]).per(40)
  end

  def votes
    if params[:actions] == 'all'
      @actions = @bill.actions
      @actions_shown = :all
    else
      @actions = @bill.major_actions
      @actions_shown = :major
    end
  end

  def actions
    @actions = @bill.actions
    @actions_shown = :all
  end

  def news
    @mentions = @bill.mentions
    @google_news_mentions = @bill.google_news_mentions
    @google_blog_mentions = @bill.google_blog_mentions

    respond_to do |format|
      format.html
      format.json { render :json => @mentions }
    end
  end

  def major_actions
    @actions = @bill.major_actions
    @actions_shown = :major

    render :template => 'bills/actions'
  end

  protected

  def setup_sort
    @sort = params[:sort] || 'introduced'

    @sorts = ActiveSupport::OrderedHash.new
    @sorts[:introduced] = 'Date Introduced'
    @sorts[:recent] = 'Recent Actions'
    @sorts[:mentions] = 'Most In The News'
    @sorts[:views] = 'Most Viewed'
    @sorts[:keyvotes] = 'Key Votes'
  end

  def scope_bills(bills)
    lim = (params[:limit] && params[:limit].to_i) || 30
    lim = (lim > 30 ? 30 : lim)
    
    # Fall back to 'introduced' if we have no MongoDB connection
    if @sort == 'views' && !MongoMapper.connected?
      @sort = 'introduced'
    end

    scope = case @sort
      when 'introduced'
        bills.order('first_action_at desc')
      when 'mentions'
        bills.joins("inner join (select owner_id as bill_id, count(mentions.id) as mention_count from mentions where owner_type = 'Bill' group by owner_id) x on bills.id = x.bill_id").order("x.mention_count desc")
      when 'views'
        bills.most_viewed(:subdomain => request.subdomain)
      when 'keyvotes'
        bills.where(:votesmart_key_vote => true)
      else
        bills.order('last_action_at desc')
    end

    scope.limit(lim)
  end

  def get_bill
    if params[:id]
      @bill = @session && @session.bills.find_by_slug(params[:id]).first
    end

    @bill || resource_not_found
  end

  def redirect_if_subsession
    # Indices are only available for primary sessions, not
    # subsessions.
    if current_session[:parent_id]
      return redirect_to(url_for(params.merge({:session => current_session.parent})))
    end
  end
end
