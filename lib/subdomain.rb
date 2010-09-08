class Subdomain  
  def self.matches?(request)  
    request.subdomain.present? && request.subdomain[0,3] != 'www' && request.subdomain != 'staging'
  end  
end