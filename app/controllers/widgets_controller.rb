class WidgetsController < SubdomainController
  layout 'widgets'
  
  def bill
    @hot_bills = Bill.most_viewed(:subdomain => request.subdomain).limit(10)
    if @hot_bills.empty?
      @hot_bills = Bill.in_a_current_session.in_chamber(@state.legislature.upper_chamber).limit(10)
    end
  end
  
end
