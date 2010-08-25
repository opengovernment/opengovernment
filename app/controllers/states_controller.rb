class StatesController < ApplicationController
  before_filter :get_state

  def show
    if @state.supported?
      @legislature = @state.legislature
      @most_recent_session = Session.most_recent(@legislature).first

      @state_key_votes = Bill.all(:conditions => {:votesmart_key_vote => true, :chamber_id => @legislature.chambers})
    else
      render :template => 'states/unsupported'
    end
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

  def search
    @query = params[:q] || ""
    @search_type = params[:search_type] || "all"
    @committee_type = params[:committee_type] || "all"

    @search_session = params[:session_id]
    @search_options = {
      :page => params[:page],
      :per_page => 15,
      :order => params[:order],
      :state_id => @state.id
    }

    case @committee_type
      when "all"
        @committee_type = Committee
      else
        @committee_type = "#{params[:committee_type]}_committee".classify.constantize
    end

    if @search_session
      @search_options[:with].merge!(:session_id => @search_session)
    end

    if @query

      case @search_type
        when "all"
          @legislators = Person.search(@query, @search_options)
          @bills = @state.bills.search(@query, @search_options)
        when "bills"
          @bills = @state.bills.search(@query, @search_options)
          @total_entries = @bills.total_entries
        when "legislators"
          @legislators = Person.search(@query, @search_options)
          @total_entries = @legislators.total_entries
        when "committees"
          @committees = @committee_type.search(@query, @search_options)
          @total_entries = @committees.total_entries
        when "contributions"
          @contributions = Contribution.search(@query, @search_options)
          @total_entries = @contributions.total_entries
      end
      render :template => "states/results.html.haml"
    else
      render :nothing => true
    end
  end

  protected
  
  def committee_type

  end
end
