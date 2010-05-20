# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def title(page_title)
    content_for(:title) { page_title }
  end

  def page_title
     "OpenGovernment - " + (yield(:title) || "revealing state and local government data")
  end
end
