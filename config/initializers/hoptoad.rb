begin
  HoptoadNotifier.configure do |config|
    config.api_key = ApiKeys.hoptoad
  end
rescue Settingslogic::MissingSetting
  Rails.logger.debug 'No hoptoad key found; hoptoad is disabled.'
end
