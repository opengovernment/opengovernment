module UrlHelper  
  
  # Given a full or short URL, return only the domain
  # and TLD. Examples:
  #   http://www.opencongress.org => opencongress.org
  #   http://news.bbc.co.uk/latest/news/ => news.bbc.co.uk
  #   www.whitehouse.gov/obama => whitehouse.gov
  def domain_for(url)
    begin
      if dom = URI.parse(url).host
        dom.sub(/www\./,'')
      end
    rescue URI::InvalidURIError
      nil
    end
  end

  def link_to_with_domain(name, url, html_options = nil)
    domain = domain_for(url)
    result = link_to(name, url, html_options) \
      + (domain ? (' <span class="link_domain small quiet">'.html_safe \
      +  '(' + domain + ')' \
      + '</span>'.html_safe) : '')
  end

  def state_url(subdomain)
    url_for(:subdomain => (subdomain.is_a?(State) ? subdomain.abbrev.downcase : subdomain), :controller => "/states", :action => "show")
  end

  def with_subdomain(subdomain)  
    subdomain = (subdomain || '')
    subdomain += '.' unless subdomain.empty?

    # Using HOST here instead of request.domain because
    # HOST can be 'staging.opengovernment.org' whereas request.domain in that case
    # would be simply 'opengovernment.org'
    [subdomain, HOST, request.port_string].join  
  end
  
  def url_for(options = nil)    
    if options.kind_of?(Hash) && options.has_key?(:subdomain)  
      options[:host] = with_subdomain(options.delete(:subdomain))  
    end

    super  
  end
end