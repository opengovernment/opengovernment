# Include hook code here
begin
  require 'erubis/helpers/rails_helper'
  require 'rails_xss'

  Erubis::Helpers::RailsHelper.engine_class = RailsXss::Erubis

  Module.class_eval do
    include RailsXss::SafeHelpers
  end

  require 'rails_xss_escaping'
  require 'av_patch'
rescue LoadError
  puts "Could not load all modules required by rails_xss. Please make sure erubis is installed an try again."
end unless $gems_rake_task