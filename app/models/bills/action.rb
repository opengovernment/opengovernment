class Action < ActiveRecord::Base
  belongs_to :bill
  default_scope :order => 'id'

  def self.by_state_and_issue(state_id, issue, limit = 10)
    find_by_sql(["select * from v_tagged_actions
            where kind_one <> 'other' and kind_one is not null and tag_name = ? and state_id = ? order by date desc limit ?", issue.name, state_id, limit])
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

  def kinds
    [kind_one, kind_two, kind_three].compact
  end

  def major?
    !kinds.empty? && !kinds.include?("other")
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

  def kind_fm
    kinds.collect do |kind|
      case kind
        when 'bill:introduced'
          'introduced'
        when 'committee:passed:unfavorable', 'committee:passed:favorable'
          'passed in committee'
        when 'governor:signed'
          'signed by the Governor'
        when 'governor:received'
          'received by the Governor'
        when 'governor:vetoed'
          'vetoed by the Governor'
        when 'governor:vetoed:line-item'
          'line-item vetoed by the Governor'
        when 'bill:passed'
          'passed'
        when 'bill:failed'
          'failed to pass'
        when 'amendment:withdrawn'
          'had an amendment withdrawn'
        when 'amendment:passed'
          'had an amendment pass'
        when 'committee:referred'
          'was referred to committee'
        when 'amendment:failed'
          'had an amendment fail'
        when 'amendment:introduced'
          'had an amendment introduced'
        when 'bill:signed'
          'signed'
      end # case
    end.join(' and ')
  end

  def kind_classes
    kinds.collect { |k| k.gsub(':', '-') }.join(' ')
  end

end

