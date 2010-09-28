module Trackable
  def page
    PageView.by_object(self.class.to_s, self.id).first
  end

  def views(since=nil)
    return 0 unless page

    if since
      page.since(since).count
    else
      page.views.count
    end
  end
end
