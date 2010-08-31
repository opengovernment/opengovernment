class Admin::StatesController < Admin::AdminController
  def index
    @s_supported = State.supported
    @s_unsupported = State.unsupported
    @s_pending = State.pending
  end

  def edit
    @state = State.find(params[:id])
  end

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
