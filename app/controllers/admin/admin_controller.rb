class Admin::AdminController < ApplicationController
  layout "admin"
  
  # Very simple admin authentication
  USERNAME, PASSWORD = 'opengov', API_KEYS['og_admin']

  def authenticate
    if Rails.env == "production"
      authenticate_or_request_with_http_basic do |username, password|
        username == USERNAME && Digest::MD5.hexdigest(password) == PASSWORD
      end
    end
  end

end
