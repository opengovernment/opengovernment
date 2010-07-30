class BillsController < ApplicationController
  before_filter :get_state
  before_filter :get_bill

  def actions
    @actions = @bill.actions

    respond_to do |format|
      format.atom { render :template => 'bills/actions' }
    end
  end

  def major_actions
    @actions = @bill.major_actions

    respond_to do |format|
      format.atom { render :template => 'bills/actions' }
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
