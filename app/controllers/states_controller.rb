class StatesController < ApplicationController
  before_filter :get_state

  def show
    if @state.supported?
      session[:preferred_location] = request.subdomains.first
      
      @legislature = @state.legislature
      @most_recent_session = Session.most_recent(@legislature).first

      @state_key_votes = Bill.where(:votesmart_key_vote => true, :state_id => @state.id).limit(5)
    else
      render :template => 'states/unsupported', :layout => 'home'
    end
  end

  def subscribe
    if request.post?
      @state.subscriptions.build(:email => params[:email])
      if @state.save
        redirect_to(root_path) and return
      end
    else
    end
  end

  def search
    @query = params[:q] || ""
    @search_type = params[:search_type] || "everything"
    @committee_type = params[:committee_type] || "all"

    # Because we are rendering a partial with @search_type in the filename,
    # sanitize this param.
    unless ['legislators','bills','committees','contributions'].include? @search_type
      @search_type = 'everything'
    end

    # We might be able to stop right here and redirect to a bill.
    # This is specifically for searched bill numbers.  Re-directing to a single
    # match in the generic case is handled below
    case @search_type
    when 'everything', 'bills'
      if @bills = Bill.for_state(@state).with_number(@query)
        if @bills.size == 1
          redirect_to(bill_path(@bills.first.session, @bills.first)) and return
        end
      end
    end

    @search_options = {
      :page => params[:page],
      :per_page => 15,
      :order => params[:order],
      :with => { :state_id => @state.id }
    }

    case @committee_type
      when "all"
        @committee_type = Committee
      else
        @committee_type = "#{params[:committee_type]}_committee".classify.constantize
    end
    
    @bill_search_options = @search_options[:with].merge(:session_id => params[:session_id]) if params[:session_id]

    if @query
      case @search_type
        when "everything"
          @legislators = Person.search(@query, @search_options)
          @bills = @state.bills.search(@query, @search_options)
          @contributions = Contribution.search(@query, @search_options)
          @committees = @committee_type.search(@query, @search_options)
        when "bills"
          @bills = @state.bills.search(@query, @bill_search_options || @search_options)
        when "legislators"
          @legislators = Person.search(@query, @search_options)
        when "committees"
          @committees = @committee_type.search(@query, @search_options)
        when "contributions"
          @contributions = Contribution.search(@query, @search_options)
      end

      @search_counts = ActiveSupport::OrderedHash.new
      @search_counts[:everything] = 0
      @search_counts[:bills] = @state.bills.search_count(@query, @bill_search_options || @search_options)
      @search_counts[:legislators] = Person.search_count(@query, @search_options)
      @search_counts[:committees] = @committee_type.search_count(@query, @search_options)
      @search_counts[:contributions] = Contribution.search_count(@query, @search_options)
      @search_counts[:everything] = @total_entries = @search_counts.values.inject() { |sum, element| sum + element }   

      if @total_entries == 1
        # go straight to the page for this object
        if @legislators && @search_counts[:legislators] == 1
          redirect_to @legislators.first
        elsif @bills && @search_counts[:bills] == 1
          redirect_to bill_path(@bills.first.session, @bills.first)
        elsif @committees && @search_counts[:committees] == 1
          redirect_to committee_path(@committees.first)
        end
      end

    else
      render :nothing => true
    end
  end

end
