module Trackable
  def page
    Page.where({:og_object_id => self.id.to_s, :og_object_type => self.class.to_s}).first
  end

  def views(since=nil)
    page.nil? ? 0 : page.views.size
  end
end
