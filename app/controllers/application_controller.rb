class ApplicationController < ActionController::Base
  include Clearance::Authentication
  helper :all
  protect_from_forgery

  filter_parameter_logging :password, :geom

  # Auth for staging environment
  USERNAME, PASSWORD = 'opengov', API_KEYS['og_staging']

  before_filter :authenticate

  private

  def authenticate
    if Rails.env == "staging"
      authenticate_or_request_with_http_basic do |username, password|
        username == USERNAME && Digest::MD5.hexdigest(password) == PASSWORD
      end
    end
  end
end
