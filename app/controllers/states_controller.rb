class StatesController < ApplicationController
  before_filter :get_state

  def show
    @state_key_votes = Bill.all(:conditions => {:votesmart_key_vote => true, :chamber_id => @state.legislature.chambers})
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
    @state = State.find_by_slug(params[:id], :include => {:legislature => {:upper_chamber => :districts, :lower_chamber => :districts}})
    @state_lower_chamber_roles = Role.current_chamber_roles(@state.legislature.lower_chamber)
    @state_upper_chamber_roles = Role.current_chamber_roles(@state.legislature.upper_chamber)
    @federal_lower_chamber_roles = Role.current.for_chamber(Legislature::CONGRESS.lower_chamber).for_state(@state).scoped({:include => [:district, :chamber, :person]})

    @state || resource_not_found
  end
end
