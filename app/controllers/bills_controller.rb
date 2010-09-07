class BillsController < ApplicationController
  before_filter :get_state
  before_filter :get_bill, :except => [:index]

  def index
    respond_to do |format|
      format.js do
        @bills = case params[:sort]
          when "actions"
            Bill.unscoped.for_state(@state).order("last_action_at desc").limit(10)
          when "recent"
            Bill.for_state(@state).limit(10)
          when "citations"
            Bill.search(:order => 'citations_count desc', :per_page => 10)
          when "views"
            Bill.find(Page.most_viewed('Bill').collect(&:og_object_id))
        end
      end
      format.html do
        @bills = Bill.unscoped.for_state(@state).order("last_action_at desc").limit(10)
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
