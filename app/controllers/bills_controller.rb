class BillsController < ApplicationController
  before_filter :get_state
  before_filter :get_bill, :except => [:index, :upper, :lower]
  before_filter :setup_sort, :only => [:index, :upper, :lower]
  before_filter :get_actions, :only => [:show, :votes]

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
    @sponsors = @bill.sponsorships.includes(:sponsor).order("people.last_name, bill_sponsorships.sponsor_name")

    respond_to do |format|
      format.js
      format.atom do
        render :template => 'shared/actions'
      end
      format.html
    end
  end

  protected
  def get_actions
    if params[:actions] && params[:actions] == 'all'
      @actions = @bill.actions
      @actions_shown = :all
    else
      @actions = @bill.major_actions
      @actions_shown = :major
    end
  end

  def setup_sort
    @sort = params[:sort] || 'recent'

    @sorts = {
      :recent => 'Recent Actions',
      :introduced => 'Date Introduced',
      :citations => 'Most In The News',
      :views => 'Most Viewed',
      :keyvotes => 'Key Votes'
    }
  end

  def scope_bills(bills)
    # Fall back to 'introduced' if we have no MongoDB connection
    if @sort == 'views' && !MongoMapper.connected?
      @sort = 'introduced'
    end

    case @sort
      when 'introduced'
        bills.order('first_action_at desc').limit(10)
      when 'citations'
        bills.search(:order => 'citations_count desc', :per_page => 10)
      when 'views'
        bills.find(Page.most_viewed('Bill').collect(&:og_object_id))
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
