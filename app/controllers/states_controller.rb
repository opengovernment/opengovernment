class StatesController < ApplicationController
  before_filter :get_state

  def show
  end

  def subscribe
    if request.post?
      @state.subscriptions.build(:email => params[:email])
      if @state.save
        redirect_to root_path
      end
    else
    end
  end

  protected
  def get_state
    #TODO: May be we should clean the routes to pass in :state as params
    @state = State.find_by_param(params[:id])|| \
              State.find_by_name(params[:id].capitalize) || \
              State.find_by_abbrev(params[:id].upcase) || \
              State.find(params[:id])

    @state || resource_not_found
  end
end
