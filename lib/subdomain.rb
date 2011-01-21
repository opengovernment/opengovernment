class Subdomain  
  def self.matches?(request)  
    request.subdomain.present? && request.subdomains.size > HOST_SUBDOMAIN_COUNT
  end

  def self.from_ip(ip)
    if GEOIP && x = GEOIP.country(ip)
      x[6].downcase 
    else
      nil
    end
  end
  
end

