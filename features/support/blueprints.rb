require 'sham'
require 'machinist/active_record'

this = File.expand_path(File.dirname(__FILE__))
Dir[File.join(Rails.root, 'spec', 'support', 'blueprints') + "/*.rb"].each do |file|
  require file
end


Dir[File.join(Rails.root, 'spec', 'support', 'macros') + "/**/*.rb"].each do |file|
  require file
end