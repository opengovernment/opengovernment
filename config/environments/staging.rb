OpenGov::Application.configure do
  # Settings specified here will take precedence over those in config/environment.rb

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the webserver when you make code changes.
  config.cache_classes = true

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  config.action_view.debug_rjs             = true

  # Disable Rails's static asset server
  # Apache will already do this
  config.serve_static_assets = false

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false

  HOST = 'staging.opengovernment.org'
  GEOSERVER_BASE_URL = "http://#{HOST}:8080/geoserver"

  config.action_mailer.default_url_options = { :host => HOST }  
end
