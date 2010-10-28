class Subdomain  
  def self.matches?(request)  
    request.subdomain.present? && request.subdomain[0,3] != 'www' && (!defined?(HOME_SUBDOMAIN) || request.subdomain != HOME_SUBDOMAIN)
  end  

  def self.from_ip(ip)
    if GEOIP && x = GEOIP.country(ip)
      x[6].downcase 
    else
      nil
    end
  end
  
end

