class BillsController < ApplicationController
  before_filter :get_state
  before_filter :get_bill, :except => [:index]

  def index
    if params[:search]
      if @state
        params[:search][:state_id] = @state.id
      end

      @bills = Bill.search(params[:search]).paginate :page => params[:page], :order => 'created_at DESC'
    else
      @bills = Bill.paginate :page => params[:page], :order => 'created_at DESC'
    end
  end

  protected

  def get_state
    if params[:state_id]
      @state = State.find_by_name(params[:state_id].capitalize)
    end
  end

  def get_bill
    if params[:id]
      @bill = @state && @state.bills.find_by_session_name_and_param(params[:session_id], params[:id])
    end

    @bill || resource_not_found
  end
end
