# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include Clearance::Authentication
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  filter_parameter_logging :password


  # Auth for staging environment
  USERNAME, PASSWORD = 'opengov', API_KEYS['og_staging']

  before_filter :authenticate

  private

  def authenticate
    authenticate_or_request_with_http_basic do |username, password|
      username == USERNAME && Digest::MD5.hexdigest(password) == PASSWORD
    end
  end

end
