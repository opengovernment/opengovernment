class Action < ActiveRecord::Base
  belongs_to :bill

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

  def kind_fm
    kinds.collect do |kind|
      case kind
        when 'bill:filed'
          'filed'
        when 'bill:introduced'
          'introduced'
        when 'bill:reading:1'
          'read for the first time'
        when 'bill:reading:2'
          'read for the second time'
        when 'bill:passed'
          'passed'
        when 'bill:failed'
          'failed to pass'
        when 'bill:signed'
          'signed'
        when 'committee:passed:unfavorable', 'committee:passed:favorable'
          'passed in committee'
        when 'committee:referred'
          'was referred to committee'
        when 'governor:signed'
          'signed by the Governor'
        when 'governor:received'
          'received by the Governor'
        when 'governor:vetoed'
          'vetoed by the Governor'
        when 'governor:vetoed:line-item'
          'line-item vetoed by the Governor'
        when 'amendment:withdrawn'
          'had amendments withdrawn'
        when 'amendment:passed'
          'had amendments pass'
        when 'amendment:amended'
          'had admendments amended'
        when 'amendment:tabled'
          'had amendments tabled'
        when 'amendment:failed'
          'had an amendment fail'
        when 'amendment:introduced'
          'had an amendment introduced'
      end # case
    end.join(' and ')
  end

  def to_md5
    Digest::MD5.hexdigest([date.to_i, kinds, action].join)
  end

  def kind_classes
    kinds.collect { |k| k.gsub(':', '-') }.join(' ')
  end

end

