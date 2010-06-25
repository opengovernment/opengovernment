class ApplicationController < ActionController::Base
  include Clearance::Authentication
  protect_from_forgery
  layout 'application'
    # Auth for staging environment
  USERNAME, PASSWORD = 'opengov', API_KEYS['og_staging']

  before_filter :authenticate

  protected
  def resource_not_found
    flash[:error] = "Sorry. We were not able to locate what you were looking for.."
    redirect_to root_path
  end

  def get_state
    if params[:state_id]
      @state = State.find_by_slug(params[:state_id])
    end
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
