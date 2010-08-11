class BillsController < ApplicationController
  before_filter :get_state
  before_filter :get_bill, :except => [:index]

  def show
    respond_to do |format|
      format.js
      format.atom do
        @actions = @bill.actions
        render :template => 'shared/actions'
      end
      format.html
    end
  end

  def major_actions
    @actions = @bill.major_actions

    respond_to do |format|
      format.atom { render :template => 'shared/actions' }
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
