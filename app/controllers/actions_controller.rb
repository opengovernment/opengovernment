class ActionsController < SubdomainController
  def show
    @action = Action.find(params[:id], :include => [:bill])
  end
end
