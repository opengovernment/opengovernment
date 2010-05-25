class CommitteesController < ApplicationController
  before_filter :get_state

  def index
    @committees = @state.committees.paginate :page => params[:page], :order => params[:order] || 'name'
  end
  
  def upper
    @committees = @state.upper_committees.paginate :page => params[:page], :order => params[:order] || 'name'
    render :template => "committees/index"
  end
  
  def lower
    @committees = @state.lower_committees.paginate :page => params[:page], :order => params[:order] || 'name'
    render :template => "committees/index"
  end

  def joint
    @committees = @state.joint_committees.paginate :page => params[:page], :order => params[:order] || 'name'
    render :template => "committees/index"
  end

  def show
    @committee = Committee.find(params[:id])
  end

end