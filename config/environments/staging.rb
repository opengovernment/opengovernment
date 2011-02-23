require 'syslog_logger'

OpenGov::Application.configure do
  # Settings specified here will take precedence over those in config/environment.rb

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the webserver when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_view.debug_rjs             = true
  config.action_controller.perform_caching = false

  # Disable Rails's static asset server
  # Apache will already do this
  config.serve_static_assets = false

  config.logger = SyslogLogger.new
  config.colorize_logging = false

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false

  config.cache_store = :mem_cache_store, '10.13.219.6:11211', { :namespace => 'opengovernment_staging' }

  # You can pass an alternative hostname in via
  # Passenger eg.
  #   <VirtualHost ...>
  #      SetEnv HOST test.dev.opengovernment.org
  #   </VirtualHost>
  #
  HOST = ENV['HOST'] || 'staging.opengovernment.org'
  HOST_SUBDOMAIN_COUNT = HOST.split('.').size - 2

  config.action_mailer.default_url_options = { :host => HOST }  
  config.active_support.deprecation = :notify

end
