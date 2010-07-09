class BillsController < ApplicationController
  before_filter :get_state
  before_filter :get_bill

  protected
  def get_bill
    if params[:id]
      @bill = @state && @state.bills.find_by_session_name_and_param(params[:session], params[:id])
    end

    @bill || resource_not_found
  end
end
