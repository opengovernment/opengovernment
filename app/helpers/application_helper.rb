module ApplicationHelper

  # Page title
  def title(page_title)
    content_for(:title) { page_title }
  end

  # Javascript hooks -- eg. document ready events. or other page-level
  # javascript that can't be accomplished via rails-ujs.
  # <script> tags should not be passed in with the js.
  def js_hook(js)
    content_for(:js_hook) { js }
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
    result = link_to(name, url, html_options) \
      + " <span class=\"link_domain\">(".html_safe \
      + domain_for(url) \
      + ")</span>".html_safe
  end
  
  def state_select
    ""
  end
end
