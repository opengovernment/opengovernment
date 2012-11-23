require 'spork'
ENV["RAILS_ENV"] ||= 'test'

Spork.prefork do
  require File.dirname(__FILE__) + "/../config/environment"
  require 'rspec/core'
  require 'rspec/rails'
  Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

#  Capybara.app = OpenGov::Application

  RSpec.configure do |config|
    config.mock_with :rspec
    config.use_transactional_fixtures = true
    config.fixture_path = "#{::Rails.root}/spec/fixtures"
  end

  ### Part of a Spork hack. See http://bit.ly/arY19y
  # Emulate initializer set_clear_dependencies_hook in
  # railties/lib/rails/application/bootstrap.rb
  ActiveSupport::Dependencies.clear
end

Spork.each_run do
end
