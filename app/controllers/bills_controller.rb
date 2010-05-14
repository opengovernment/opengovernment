class BillsController < ApplicationController
  before_filter :get_bill

  def index
    @bills = Bill.search(params[:search])
  end

  protected
  def get_bill
    if params[:state_id] && params[:id]
      @state = State.find_by_name(params[:state_id].capitalize)
      @bill = @state && @state.bills.find_by_session_name_and_param(params[:session_id], params[:id])
    end

    @bill || resource_not_found
  end
end
