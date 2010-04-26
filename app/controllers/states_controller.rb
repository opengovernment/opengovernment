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
    @state = State.find(params[:id])
    @state || resource_not_found
  end
end
