class Action < ActiveRecord::Base
  belongs_to :bill

  def description
    "The " + actor.capitalize + " chamber performed '" + action + "' on " + date.to_s(:pretty)
  end
  
  def actor_fm
    actor.capitalize
  end
end
