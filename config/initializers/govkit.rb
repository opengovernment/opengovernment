if defined? GovKit
  GovKit.configure do |config|
    # Get an API key for Sunlight's Open States project here:
    # http://services.sunlightlabs.com/accounts/register/
    config.sunlight_apikey = ApiKeys.sunlight_labs
    config.votesmart_apikey = ApiKeys.votesmart
    config.ftm_apikey = ApiKeys.follow_the_money
    config.technorati_apikey = ApiKeys.technorati
    config.bing_appid = ApiKeys.bing
  end
end
