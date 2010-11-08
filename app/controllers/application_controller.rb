class ApplicationController < ActionController::Base
  include UrlHelper
  helper_method :current_place, :current_place_name, :current_place_subdomain
  before_filter :set_locale

  protect_from_forgery
  
  layout :layout_by_resource

  def layout_by_resource
    if devise_controller? && request.xhr?
      "popup"
    elsif devise_controller?
      "pages"
    else
      "application"
    end
  end

  def set_locale
    I18n.locale = extract_locale_from_subdomain
  end

  # Get locale from top-level domain or return nil if such locale is not availabl
  # You have to put something like:
  def extract_locale_from_subdomain
    return nil unless request.subdomains.first
    parsed_locale = 'en-' + request.subdomains.first.upcase
    I18n.available_locales.include?(parsed_locale.to_sym) ? parsed_locale : nil
  end

  protected
  def resource_not_found
    flash[:error] = "Sorry. We were not able to locate what you were looking for.."
    redirect_to(home_url(:subdomain => false))
  end

  def get_state
    @state = lookup_state(request.subdomain)
    @state || resource_not_found
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

  private
  def lookup_state(subdomain)
    return State.find_by_slug(subdomain) || State.find_by_slug(subdomain.sub(/\..*$/,''))
  end
end
