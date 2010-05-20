# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def title(page_title)
    content_for(:title) { page_title }
  end

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
    result = link_to(name, url, html_options) + " <span class=\"link_domain\">(" + domain_for(url) + ")</span>"
    result.html_safe!
  end

end
