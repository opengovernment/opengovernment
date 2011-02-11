OpenGov::Application.configure do
  # Settings specified here will take precedence over those in config/environment.rb

  # The production environment is meant for finished, "live" apps.
  # Code is not reloaded between requests
  config.cache_classes = true

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Specifies the header that your server uses for sending files
  config.action_dispatch.x_sendfile_header = "X-Sendfile"

  # For nginx:
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect'

  # If you have no front-end server that supports something like X-Sendfile,
  # just comment this out and Rails will serve the files

  # See everything in the log (default is :info)
  # config.log_level = :debug

  # Use a different logger for distributed setups
  # config.logger = SyslogLogger.new
  config.active_support.deprecation = :notify

  # Use a different cache store in production
  config.cache_store = :mem_cache_store, '10.13.219.6:11211', { :namespace => 'opengovernment_production' }

  # Disable Rails's static asset server
  # In production, Apache or nginx will already do this
  config.serve_static_assets = false

  # Disable delivery errors, bad email addresses will be ignored
  # config.action_mailer.raise_delivery_errors = false
  HOST = ENV['HOST'] || 'opengovernment.org'
  HOST_SUBDOMAIN_COUNT = HOST.split('.').size - 2

  # Enable serving of images, stylesheets, and javascripts from CloudFront
  config.asset_host = Proc.new { |source, request|
    "#{request.ssl? ? 'https' : 'http'}://d20tbjzc77cxpv.cloudfront.net"
  }

  # This is the cache-busting code for CloudFront. CloudFront ignores the date stamp that Rails typically
  # adds to asset URLs for cache busting, so we have to add a subdirectory to the asset path based on
  # the current git revision.
  #
  # This corresponds to an Apache rewrite rule that effectively ignores the /r-{RELEASE_NUMBER}/ part:
  # 
  #  RewriteRule ^/r-.+/(images|javascripts|stylesheets|system|assets)/(.*)$ /$1/$2 [L]

  # Use the git revision of this release
  RELEASE_NUMBER = %x{cat REVISION | cut -c -7}.rstrip

  config.asset_path = Proc.new { |asset_path|  
    "/r-#{RELEASE_NUMBER}#{asset_path}"  
  }

  config.action_mailer.default_url_options = {:host => HOST}
end
