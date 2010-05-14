source :gemcutter
source "http://gems.github.com"

gem 'rails', '2.3.5'

# ActiveRecord requires a database adapter.
gem "pg"

# An alternative form builder
gem "formtastic"

# Basic authentication
gem "clearance"

# GIS functionality
gem "GeoRuby"
gem "spatial_adapter"
gem "ym4r"

# Service integration
gem "netroots-ruby-votesmart", :require => "ruby-votesmart"

# Geocoding
gem "geokit"

# Place hierarchy
# gem "ancestry"

# HAML!
gem "haml"

# Required for rails_xss plugin, which turns on XSS protection by default;
# remove this (and the plugin) for Rails 3
gem "erubis"

# Importing & parsing stuff
gem "httparty"
gem "hpricot"

# Asset packaging
gem "jammit"

## Bundle gems used only in certain environments:
group :cucumber do
   gem "cucumber-rails"
   gem "database_cleaner"
   gem "webrat"
   gem "factory_girl"
end

group :test, :cucumber do
   gem "rspec"
   gem "rspec-rails"
   gem "faker"
   gem "machinist"
   gem "ruby-debug"
   gem "spork"
   gem "webrat"
end
