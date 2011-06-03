class ApplicationController < ActionController::Base
  include UrlHelper
  protect_from_forgery

  helper_method :current_place, :current_place_name, :current_place_subdomain, :current_session, :current_session_name, :default_session?

  layout :layout_by_resource

  def layout_by_resource
    if request.headers['X-PJAX']
      # jquery-pjax support (see https://github.com/defunkt/jquery-pjax)
      false
    elsif request.xhr?
      # for ajax modals via jquery.colorbox.js
      "popup"
    elsif devise_controller?
      "pages"
    else
      "application"
    end
  end

  def current_session
    @session ||= lookup_session(params[:session])
  end
  
  def default_session?
    current_session.try(:latest?)
  end

  def current_session_name
    current_session.try(:name_fm)
  end

  def current_place
    @state ||= lookup_state(request.subdomain)
  end

  def current_place_name
    current_place.try(:name)
  end

  def current_place_subdomain
    current_place.try(:abbrev).try(:downcase)
  end

  protected
  def resource_not_found
    render 'public/404.html', :layout => false, :status => 404
  end

  # Is this a request from a robot?
  def is_megatron?
    request.user_agent =~ /\b(Baidu|Gigabot|Googlebot|libwww-perl|lwp-trivial|msnbot|SiteUptime|Slurp|WordPress|ZIBB|ZyBorg)\b/i
  end

  private
  def lookup_state(subdomain)
    return State.find_by_slug(subdomain) || State.find_by_slug(subdomain.sub(/\..*$/,''))
  end

  def lookup_session(param = nil)
    legislature = @state && @state.legislature

    unless legislature.blank?
      unless param.blank?
        return Session.where(["legislature_id = ? and upper(sessions.name) like upper(?)", legislature.id, param.gsub(/-/,'_')]).try(:first) || resource_not_found
      else
        return Session.most_recent(legislature).first
      end
    end

    nil
  end

end
