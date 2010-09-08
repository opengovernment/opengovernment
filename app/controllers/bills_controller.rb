class BillsController < ApplicationController
  before_filter :get_state
  before_filter :get_bill, :except => [:index]

  def index
    @state_bills = Bill.for_state(@state).unscoped

    respond_to do |format|
      format.js do

        @bills = case params[:sort]
          when "actions"
            @state_bills.order("last_action_at desc").limit(10)
          when "recent"
            @state_bills.limit(10)
          when "citations"
            @state_bills.search(:order => 'citations_count desc', :per_page => 10)
          when "views"
            @state_bills.find(Page.most_viewed('Bill').collect(&:og_object_id))
          when "keyvotes"
            legislature = @state.legislature
            @state_bills.find(:all, :conditions => {:votesmart_key_vote => true, :chamber_id => legislature.chambers})
        end
      end
      format.html do
        @bills = @state_bills.order("last_action_at desc").limit(10)
      end
    end
  end

  def show
    if params[:actions] && params[:actions] == "all"
      @actions = @bill.actions
    else
      @actions = @bill.major_actions
    end

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
