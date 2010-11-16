class BillsController < ApplicationController
  before_filter :get_state
  before_filter :get_bill, :except => [:index, :upper, :lower]
  before_filter :setup_sort, :only => [:index, :upper, :lower]

  def index
    @bills = scope_bills(Bill.for_state(@state))
    @current_tab = :all
  end

  def upper
    @bills = scope_bills(Bill.for_state(@state).in_chamber(@state.legislature.upper_chamber))
    @current_tab = :upper
    render :template => 'bills/index'
  end
  
  def lower
    @bills = scope_bills(Bill.for_state(@state).in_chamber(@state.legislature.lower_chamber))
    @current_tab = :lower
    render :template => 'bills/index'
  end

  def show
    @sponsors = @bill.sponsorships.includes(:sponsor).order("people.last_name, bill_sponsorships.sponsor_name").limit(10)
    @sponsor_count = @bill.sponsorships.count
    @votes = @bill.votes
    @actions = @bill.actions
  end
  
  def sponsors
    @sponsors = @bill.sponsorships.includes(:sponsor).order("people.last_name, bill_sponsorships.sponsor_name")
    render :layout => 'popup'
  end
  
  def documents
    @documents = @bill.documents.paginate :page => params[:page], :per_page => 40
    render :layout => 'popup'
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

  def major_actions
    @actions = @bill.major_actions
    @actions_shown = :major

    render :template => 'bills/actions'
  end

  protected

  def setup_sort
    @sort = params[:sort] || 'recent'

    @sorts = ActiveSupport::OrderedHash.new
    @sorts[:recent] = 'Recent Actions'
    @sorts[:introduced] = 'Date Introduced'
    @sorts[:mentions] = 'Most In The News'
    @sorts[:views] = 'Most Viewed'
    @sorts[:keyvotes] = 'Key Votes'

    puts @sorts.inspect
  end

  def scope_bills(bills)
    # Fall back to 'introduced' if we have no MongoDB connection
    if @sort == 'views' && !MongoMapper.connected?
      @sort = 'introduced'
    end

    case @sort
      when 'introduced'
        bills.order('first_action_at desc').limit(10)
      when 'mentions'
        bills.joins("inner join (select owner_id as bill_id, count(mentions.id) as mention_count from mentions where owner_type = 'Bill' group by owner_id) x on bills.id = x.bill_id").order("x.mention_count desc").limit(10)
      when 'views'
        # This is gnarly. We have to generate a case statement for PostgreSQL in order to
        # get the people out in page view order. AND we need an SQL in clause for the people.

        # It does result in only one SQL call, though.
        # Good thing this is only ever limited to 10 or 20 people.
        countable_ids = Page.most_viewed('Bill').collect(&:countable_id)

        bills.find_in_explicit_order('bills.id', countable_ids)
      when 'keyvotes'
        bills.where(:votesmart_key_vote => true, :chamber_id => @state.legislature.chambers)
      else
        bills.order('last_action_at desc').limit(10)
    end
  end

  def get_bill
    if params[:id]
      @bill = @state && @state.bills.find_by_session_name_and_param(params[:session], params[:id])
    end

    @bill || resource_not_found
  end
end
