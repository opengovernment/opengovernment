class ApplicationController < ActionController::Base
 # include BreadcrumbsOnRails::ControllerMixin
  include Clearance::Authentication
  include UrlHelper
 # helper_method :current_place

  protect_from_forgery
  layout 'application'
    # Auth for staging environment
  USERNAME, PASSWORD = 'opengov', API_KEYS['og_staging']

  protected
  def resource_not_found
    flash[:error] = "Sorry. We were not able to locate what you were looking for.."
    redirect_to root_path
  end

  def get_state
    @state = State.find_by_slug(request.subdomain)
    @state || resource_not_found
  end

  private
  def authenticate
    if Rails.env == "staging"
      authenticate_or_request_with_http_basic do |username, password|
        username == USERNAME && Digest::MD5.hexdigest(password) == PASSWORD
      end
    end
  end
end
