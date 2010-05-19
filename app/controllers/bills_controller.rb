class BillsController < ApplicationController
  before_filter :get_state
  before_filter :get_bill, :except => [:index]

  def index
    params.delete(:order) unless params[:order] && Bill::SORTABLE_BY.include?(params[:order])

    @bills = Bill.search(params).paginate :page => params[:page], :order => params[:order] || 'created_at DESC'
    
    respond_to do |format|
      format.html
      format.atom
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
