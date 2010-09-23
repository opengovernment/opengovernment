module BillHelper

  def sponsor_mugs(sponsors, options = {})
    mugs = ''.html_safe
    i = 0
    limit = options.delete(:limit) || 0
    summary = options.delete(:summary) || false
    
    sponsors.each do |s|
     if s.sponsor_id? && !s.sponsor.photo_url.blank?
       mugs += link_to(photo_for(s.sponsor, :tiny), person_path(s.sponsor), :rel => 'tipsy', :title => s.sponsor.full_name + ', ' + s.kind_fm, :class => 'sponsor_mug')
       i += 1
     end
     break if i == limit && limit > 0
    end
    
    sponsors_left = sponsors.size - i
    if summary && sponsors_left > 0 && !mugs.blank?
      mugs + content_tag(:span, "and #{pluralize(sponsors_left, 'other')}.")
    else
      mugs
    end
  end
end
