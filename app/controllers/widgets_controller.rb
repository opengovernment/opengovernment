class WidgetsController < SubdomainController
  layout 'widgets'
  
  def bill
    @hot_bills = Bill.most_viewed(:subdomain => request.subdomain, :limit => 10)
  end
  
end
