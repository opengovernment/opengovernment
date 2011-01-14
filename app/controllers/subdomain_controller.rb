class SubdomainController < ApplicationController
  # All controllers that are called via a subdomain should inherit from this one.
  before_filter :set_locale
  before_filter :get_state_and_session

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

  def get_state_and_session
    @state = lookup_state(request.subdomain)
    return resource_not_found unless @state
    
    @session = lookup_session(params[:session])
    @available_sessions = Session.major.complete.where("legislature_id = ?", @state.legislature).order("start_year desc, parent_id nulls first")
  end

end
