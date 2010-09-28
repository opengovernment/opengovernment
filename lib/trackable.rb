module Trackable
  def page
    Page.by_object(self.class.to_s, self.id).first
  end

  def views(since=nil)
    return 0 unless page

    if since
      page.view_count_since(since)
    else
      page.view_count
    end
  end
end
