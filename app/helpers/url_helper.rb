module UrlHelper  
  
  # Given a full or short URL, return only the domain
  # and TLD. Examples:
  #   http://www.opencongress.org => opencongress.org
  #   http://news.bbc.co.uk/latest/news/ => news.bbc.co.uk
  #   www.whitehouse.gov/obama => whitehouse.gov
  def domain_for(url)
    if dom = URI.parse(url).host
      dom.sub(/www\./,'')
    end
  end

  def link_to_with_domain(name, url, html_options = nil)
    result = link_to(name, url, html_options) \
      + " <span class=\"link_domain\">(".html_safe \
      + domain_for(url) \
      + ")</span>".html_safe
  end

  def state_url(subdomain)
    url_for(:subdomain => (subdomain.is_a?(State) ? subdomain.abbrev.downcase : subdomain), :controller => "states", :action => "show")
  end

  def with_subdomain(subdomain)  
    subdomain = (subdomain || '')
    subdomain = HOME_SUBDOMAIN if subdomain.empty? && defined?(HOME_SUBDOMAIN)
    subdomain += '.' unless subdomain.empty?  

    domain = request.domain
    domain = HOST if defined?(HOME_SUBDOMAIN)

    [subdomain, domain, request.port_string].join  
  end
  
  def url_for(options = nil)
    if options.kind_of?(Hash) && options.has_key?(:subdomain)  
      options[:host] = with_subdomain(options.delete(:subdomain))  
    end
    super  
  end
end