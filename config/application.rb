require File.expand_path('../boot', __FILE__)

require 'rails/all'

# If you have a Gemfile, require the gems listed there, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env) if defined?(Bundler)

module OpenGov
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Add additional load paths for your own custom dirs
    config.autoload_paths += %W(#{config.root}/lib #{config.root}/app/models/committees #{config.root}/app/models/chambers #{config.root}/app/models/bills)

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named
    #config.plugins = [ :exception_notification, :ssl_requirement ]

    # Activate observers that should always be running
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.

    # Prefer the default locale, :en.
    config.i18n.fallbacks = true

    # Configure generators values. Many other options are available, be sure to check the documentation.
    config.generators do |g|
       g.orm             :active_record
       g.template_engine :haml
       g.test_framework  :rspec, :fixture => true
    end

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    config.active_record.timestamped_migrations = false

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password, :geom]
  end
end

API_KEYS = YAML::load(File.open(File.join(File.dirname(__FILE__), 'api_keys.yml')))
DATA_DIR = Rails.root.join("data")
DISTRICTS_DIR = File.join(DATA_DIR, "districts")
GOVTRACK_DIR = File.join(DATA_DIR, "govtrack")
OPENSTATES_DIR = File.join(DATA_DIR, "openstates")

require 'acts_as_taggable_on'
require 'extensions'
