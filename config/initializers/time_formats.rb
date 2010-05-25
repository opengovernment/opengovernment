ActiveSupport::CoreExtensions::Date::Conversions::DATE_FORMATS.merge!(
  :default => '%B %e, %Y',
  :slashed => '%m/%d/%Y',
  :no_year => '%B %e, %a',
  :date_time12  => "%m/%d/%Y %I:%M%p",
  :date_time24  => "%m/%d/%Y %H:%M"
)
