require 'rubygems'
require 'spork'

Spork.prefork do

  # Loading more in this block will cause your tests to run faster. However, 
  # if you change any configuration or code from libraries loaded here, you'll
  # need to restart spork for it take effect.

  ENV["RAILS_ENV"] ||= 'test'

  unless defined?(Rails)
    require File.dirname(__FILE__) + "/../config/environment"
  end

  require 'rspec'

  # Requires supporting files with custom matchers and macros, etc,
  # in ./support/ and its subdirectories.
  Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

  RSpec.configure do |config|
    config.mock_with :rspec
    config.use_transactional_fixtures = true
    config.fixture_path = "#{::Rails.root}/spec/fixtures"
    config.global_fixtures = :all
  end

  ### Part of a Spork hack. See http://bit.ly/arY19y
  # Emulate initializer set_clear_dependencies_hook in 
  # railties/lib/rails/application/bootstrap.rb
  #ActiveSupport::Dependencies.clear
end

Spork.each_run do
  # This code will be run each time you run your specs.
  
end
