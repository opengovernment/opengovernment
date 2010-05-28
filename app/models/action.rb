class Action < ActiveRecord::Base
  belongs_to :bill

  def description
    "The " + actor_fm + " performed '" + action + "' on " + date.to_s(:pretty)
  end
  
  def actor_fm
    case actor
    when "lower":
      bill.state.legislature.lower_chamber.name
    when "upper":
      bill.state.legislature.upper_chamber.name
    when "executive":
      "executive branch"
    end
  end
  
  def action_fm
    case action.downcase
    when /^vote/, /^(committee|comte|comm.)/, /suspended|cancelled/, /^nonrecord vote/, /^statement/, /^amendment/, /^remarks/:
      "had its " + action.downcase
    when "point of order":
      "had a point of order raised"
    when /point of order(.*)/:
      "had a point of order#{$1}"
    when /^(co-)?author/, /^motion/:
      "had a " + action.downcase
    when /testimony taken in(.*)$/:
      "testimony was taken in #{$1}"
   when /grants/, /appoints/, /requests/, /refuses/, /adopts/:
      action.downcase
    when /^read\s+([^\s]+)\s+time/:
      "was read for the #{$1} time"
    when "record vote":
      "had its vote recorded"
    else
      "was " + action.downcase
    end
  end
end

