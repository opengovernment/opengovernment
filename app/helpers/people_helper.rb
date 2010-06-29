module PeopleHelper
  def sponsorship_vitals_for(person)
     t = "<span class='sponsorship_vitals'>"
     if s = @person.current_sponsorship_vitals
      t += link_to(s.bill_count, sponsored_bills_person_url(@person)) + " bills sponsored or co-sponsored <span class='rank'>(ranks " + s.rank.to_i.ordinalize + " out of " + s.total_sponsors + ")</span>"
    else
      t += "No sponsorship information available"
    end
    t += "</span>"
    t.html_safe
  end
end
