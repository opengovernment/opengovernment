require 'extensions/date'
require 'extensions/integer'
if Rails && Rails.env == "test"
  require 'extensions/rspec/integration_example_group'
end