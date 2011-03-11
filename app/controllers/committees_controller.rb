class CommitteesController < SubdomainController
  respond_to :html, :json

  def index
    @committees = @state.committees.paginate :page => params[:page], :order => params[:order] || 'name'
    respond_with(@committees)
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
    
    respond_with(@committee) do |format|
      format.json {
        render :json => @committee, :include => :committee_memberships
      }
    end
  end

end