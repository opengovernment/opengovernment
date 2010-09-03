class Action < ActiveRecord::Base
  belongs_to :bill
  default_scope :order => 'actions.date desc'

  class << self
    def find_all_by_issue(issue)
      find_by_sql(["select * from v_tagged_actions
              where kind <> 'other' and kind is not null and tag_name = ? order by date desc", issue.name])
    end
  end

  def description
    "The " + actor_fm + " performed '" + action + "' on " + date.to_s(:pretty)
  end

  def actor_fm
    case actor
      when /^lower/
        bill.state.legislature.lower_chamber.name
      when /^upper/
        bill.state.legislature.upper_chamber.name
      when 'executive', 'governor'
        "executive branch"
      else
        actor
    end
  end

  def major?
    !kind.blank? && kind != "other"
  end

  def action_fm
    case action.downcase
      when /^vote/, /^(committee|comte|comm.)/, /suspended|cancelled/, /^nonrecord vote/, /^statement/, /^remarks/
        "had its " + action.downcase
      when /^amendment/
        "had " + action.downcase
      when "point of order"
        "had a point of order raised"
      when /point of order(.*)/
        "had a point of order#{$1}"
      when /^(co-)?author/, /^motion/
        "had a " + action.downcase
      when /testimony taken in(.*)$/
        "testimony was taken in #{$1}"
      when /grants/, /appoints/, /requests/, /refuses/, /adopts/
        action.downcase
      when /^read\s+([^\s]+)\s+time/
        "was read for the #{$1} time"
      when "record vote"
        "had its vote recorded"
      else
        "was " + action.downcase
    end
  end
end

