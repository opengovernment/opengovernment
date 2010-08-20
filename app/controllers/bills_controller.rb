class BillsController < ApplicationController
  before_filter :get_state
  before_filter :get_bill, :except => [:index]
  
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
