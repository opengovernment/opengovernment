module PeopleHelper
  def sponsorship_vitals_for(person)
    render 'people/sponsorship_vitals', :vitals => @person.current_sponsorship_vitals
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
