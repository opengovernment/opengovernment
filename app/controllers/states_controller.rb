class StatesController < SubdomainController
  def show
    if @state.supported?
      respond_to do |format|
        format.json {
          render :json => @state
        }
        format.html {
          session[:preferred_location] = request.subdomains.first

          bill = Bill.where(:session_id => @session.family).limit(5)
          @key_votes = bill.where(:votesmart_key_vote => true)
          @recent_bills = bill.order('last_action_at desc')
          @most_viewed_bills = bill.most_viewed(:subdomain => request.subdomain, :limit => 5) || []

          @hot_people = Person.find_by_sql(["select
            p.*,
            current_district_name_for(p.id) as district_name,  
            current_party_for(p.id) as party,
            m.mentions_count
          from
            people p join (
              select
                count(*) mentions_count,
                owner_id
              from mentions m join roles r on (r.person_id = m.owner_id)
              where m.owner_type = 'Person'
                and r.session_id = ?
              group by owner_id
              order by mentions_count desc
              limit 50) m
            on m.owner_id = p.id
          where
            p.photo_url is not null
          limit 12
          ", @session.id])
        }
      end
    else
      render :template => 'states/unsupported', :layout => 'home'
    end
  end

  def search
    @query = params[:q] || ""
    @query = @query.gsub(/([$^])/, '')

    @search_type = params[:search_type] || "everything"
    @committee_type = params[:committee_type] || "all"

    # Because we are rendering a partial with @search_type in the filename,
    # sanitize this param.
    unless ['legislators','bills','committees'].include? @search_type
      @search_type = 'everything'
    end

    @search_options = {
      :order => params[:order],
      :with => { :state_id => @state.id }
    }

    case @search_type
    when 'everything', 'bills'
      # We might be able to stop right here and redirect to a bill.
      # This is specifically for searched bill numbers.  Re-directing to a single
      # match in the generic case is handled below
      if @bills = Bill.for_state(@state).with_number(@query)
        if @bills.size == 1
          redirect_to(bill_path(@bills.first.session, @bills.first)) and return
        end
      end

      # Session filtering
      # We look for nil values here so we can always capture all of the legislators & committees when we're counting results with .facets
      @search_options[:with][:session_id] = [params[:session_id], nil] if params[:session_id]
    end

    case @committee_type
      when "all"
        @committee_type = Committee
      else
        @committee_type = "#{params[:committee_type]}_committee".classify.constantize
    end

    if @query
      case @search_type
        when "everything"
          @legislators = Person.search(@query, @search_options).page(params[:page])
          @bills = Bill.search(@query, @search_options).page(params[:page])
          @committees = @committee_type.search(@query, @search_options).page(params[:page])
        when "bills"
          @bills = Bill.search(@query, @search_options).page(params[:page])
        when "legislators"
          @legislators = Person.search(@query, @search_options).page(params[:page])
        when "committees"
          @committees = @committee_type.search(@query, @search_options).page(params[:page])
      end

      @facets = ThinkingSphinx.facets(@query, @search_options)

      @search_counts = ActiveSupport::OrderedHash.new
      @search_counts[:everything] = 0
      @search_counts[:bills] = @facets[:class]['Bill']
      @search_counts[:legislators] = @facets[:class]['Person']
      @search_counts[:committees] = @facets[:class][@committee_type.to_s]
      @search_counts[:everything] = @total_entries = @search_counts.values.inject() { |sum, element| sum + (element || 0) }   

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
