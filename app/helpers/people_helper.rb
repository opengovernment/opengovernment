module PeopleHelper
  def sponsorship_vitals_for(person)
     t = "<span class='sponsorship_vitals'>".html_safe
     if s = @person.current_sponsorship_vitals
      t += link_to(s.bill_count, sponsored_bills_person_url(@person)) + " bills sponsored or co-sponsored <span class='rank'>(ranks ".html_safe + s.rank.to_i.ordinalize + " out of " + s.total_sponsors + ")</span>".html_safe
    else
      t += "No sponsorship information available"
    end
    t += "</span>".html_safe
    t.html_safe
  end

  def year_span(start_date, end_date)
    return '' if start_date.blank? && end_date.blank?
    
    tag = time_tag(start_date, start_date.try(:year)) + "&ndash;".html_safe + time_tag(end_date, end_date.try(:year))
    raw '(' + tag + ')'
  end

  def time_tag(time, content)
    content_tag(:time, content, :datetime => time) unless time.blank?
  end

end
