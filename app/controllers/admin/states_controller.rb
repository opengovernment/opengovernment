class Admin::StatesController < Admin::ApplicationController
  # GET /admin/states
  def index
    @s_supported = State.supported
    @s_unsupported = State.unsupported
    @s_pending = State.pending
  end

  # GET /admin/states/ca/edit
  def edit
    @state = State.find(params[:id])
  end

  # PUT /admin/states/ca
  # PUT /admin/states/ca.xml
  def update
    @state = State.find(params[:id])
    if @state.update_attributes(params[:state])
        flash[:notice] = "State updated successfully."
        redirect_to(admin_states_url)
    else
        render :action => :edit
    end
  end

end
