Time::DATE_FORMATS.merge!(
  :default => '%B %e, %Y',
  :slashed => '%m/%d/%Y',
  :no_year => '%B %e, %a',
  :date_time12  => "%m/%d/%Y %I:%M%p",
  :date_time24  => "%m/%d/%Y %H:%M",
  :timetag => '<time datetime="%Y-%m-%d" class="fancy-date"><span class="date-month">%b</span><span class="date-day">%e</span><span class="date-year">%Y</span></time>',
  :pretty => lambda do |d|
      if (Time.now.year*12 + Time.now.month) - (d.year*12 + d.month) < 12
        d.strftime("%b %e")
      else
        d.strftime("%b %e, %Y")
      end
    end
)
