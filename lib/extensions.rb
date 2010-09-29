require 'extensions/date'
require 'extensions/integer'
require 'extensions/bread'
require 'extensions/string'
require 'extensions/mongo_mapper'
require 'extensions/time'
require 'extensions/explicit_order'
if Rails && Rails.env == "test"
  require 'extensions/rspec/integration_example_group'
end
