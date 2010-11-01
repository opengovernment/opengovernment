class Admin::AdminController < ApplicationController
  before_filter :authenticate
  layout "admin"
  
  # Very simple admin authentication
  USERNAME, PASSWORD = 'opengov', ApiKeys.og_admin

  def authenticate
    if Settings.enable_simple_admin_authentication
      authenticate_or_request_with_http_basic do |username, password|
        username == USERNAME && Digest::MD5.hexdigest(password) == PASSWORD
      end
    end
  end
end
