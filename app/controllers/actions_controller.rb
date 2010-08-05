class ActionsController < ApplicationController
  def show
    @action = Action.find(params[:id], :include => [:bill])
  end
end
