module ApplicationHelper

  # Page title
  def title(page_title)
    content_for(:title) { page_title }
  end

  # Javascript hooks -- eg. document ready events. or other page-level
  # javascript that can't be accomplished via rails-ujs.
  # <script> tags should not be passed in with the js.
  def javascript
    content_for(:js_hook) { yield }
  end

  def track(object)
    javascript do
      %Q|
          $(document).ready(function() {
            Tracker.req.object_id = #{object.id};
            Tracker.req.object_type = '#{object.class}';
            Tracker.track();
          });
        |
    end
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

  def state_url(subdomain)
    url_for(:subdomain => (subdomain.is_a?(State) ? subdomain.abbrev.downcase : subdomain), :controller => "states", :action => "show")
  end

  def photo_for(person, size = :full)
    ops = case size
    when :thumb
      {:width => 50, :height => 50}
    else
      {:width => 110, :height => 110}
    end

    if person.photo?
      # The local photo
      image_tag(person.photo.url(size), ops)
    elsif person.photo_url(size)
      # The remote photo, as a backup
      image_tag(person.photo_url(size), ops)
    else
      # No photo.
      image_tag('missing.png', ops)
    end
  end
end
