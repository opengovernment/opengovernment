class BillsController < ApplicationController
  before_filter :get_bill

  protected
  def get_bill
    if params[:state_id] && params[:id]
      state = State.find_by_name(params[:state_id].capitalize)
      @bill = state && state.bills.find_by_param(params[:id])
    end

    if params[:person_id] && params[:id]
      person = Person.find(params[:person_id])
      @bill = person && Bill.find_by_param(params[:id]) 
    end

    @bill || resource_not_found
  end
end
