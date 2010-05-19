class Action < ActiveRecord::Base
  belongs_to :bill

  def description
    "The " + actor.capitalize + " chamber performed '" + action + "' on " + pretty_date
  end
  
  def pretty_date
    s = self[:date].strftime("%B %d")
    s << self[:date].strftime(", %Y") if self[:date].year != Time.now.year
    s
  end
end
