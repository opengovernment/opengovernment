if defined? Govkit
  
  Govkit.configure do |config|
    # Get an API key for Sunlight's Fifty States project here:
    # http://services.sunlightlabs.com/accounts/register/
    config.fiftystates_apikey = API_KEYS['sunlight_labs']
  end

end
