class CommitteesController < ApplicationController
  before_filter :get_state

  def index
    @committees = @state.committees.paginate :page => params[:page], :order => params[:order] || 'name'
  end

end