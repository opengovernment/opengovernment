require 'rubygems'
require 'spork'
Spork.prefork do
  ENV["RAILS_ENV"] ||= 'test'
  require File.expand_path(File.join(File.dirname(__FILE__),'..','config','environment'))
  require 'spec/autorun'
  require 'spec/rails'

  # Uncomment the next line to use webrat's matchers
  require 'webrat/integrations/rspec-rails'

  # Requires supporting files with custom matchers and macros, etc,
  # in ./support/ and its subdirectories.
  Dir[File.expand_path(File.join(File.dirname(__FILE__),'support','**','*.rb'))].each {|f| require f}
end

Spork.each_run do
  Spec::Runner.configure do |config|
    config.use_transactional_fixtures = true
    config.use_instantiated_fixtures = false
    config.fixture_path = RAILS_ROOT + '/spec/fixtures/'
    config.global_fixtures = :all
  end
end
