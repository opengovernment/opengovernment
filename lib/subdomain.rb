class Subdomain  
  def self.matches?(request)  
    request.subdomain.present? && request.subdomain[0,3] != 'www' && (!defined?(HOME_SUBDOMAIN) || request.subdomain != HOME_SUBDOMAIN)
  end  
end