class BillsController < ApplicationController
  before_filter :get_state
  before_filter :get_bill, :except => [:index]

  def index
    @sort = params[:sort] || 'introduced'

    @sorts = {:introduced => 'Date Introduced',
      :recent => 'Recent Actions',
      :citations => 'Most In The News',
      :views => 'Most Viewed',
      :keyvotes => 'Key Votes'}

    @state_bills = Bill.for_state(@state)
    @bills = case params[:sort]
      when 'introduced'
        @state_bills.order('first_action_at desc').limit(10)
      when 'citations'
        @state_bills.search(:order => 'citations_count desc', :per_page => 10)
      when 'views'
        @state_bills.find(Page.most_viewed('Bill').collect(&:og_object_id))
      when 'keyvotes'
        @state_bills.where(:votesmart_key_vote => true, :chamber_id => @state.legislature.chambers)
      else
        @state_bills.order('last_action_at desc').limit(10)
    end

    respond_to do |format|
      format.js
      format.html
    end
  end

  def show
    if params[:actions] && params[:actions] == 'all'
      @actions = @bill.actions
    else
      @actions = @bill.major_actions
    end
    
    @sponsors = @bill.sponsorships.includes(:sponsor).order("people.last_name, sponsorships.sponsor_name")

    respond_to do |format|
      format.js
      format.atom do
        render :template => 'shared/actions'
      end
      format.html
    end
  end

  protected
  def get_bill
    if params[:id]
      @bill = @state && @state.bills.find_by_session_name_and_param(params[:session], params[:id])
    end

    @bill || resource_not_found
  end
end
