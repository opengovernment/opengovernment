# http://mattbeedle.com/2010/07/04/testing-subdomains-with-cucumber-cabybara-and-rack-test

Before do
  Capybara.default_host = 'www.example.com'
end

When /^I visit subdomain "(.+)"$/ do |sub|
  Capybara.default_host = "#{sub}.www.example.com" #for Rack::Test
  Capybara.app_host = "http://#{sub}.www.example.com:9887" if Capybara.current_driver == :culerity

  # To test with non-Rack drivers you may have to add the
  # {sub}.www.example.com domains to your /etc/hosts file.
end
