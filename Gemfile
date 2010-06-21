source 'http://rubygems.org'

gem 'rails', '3.0.0.beta4'
#gem 'rails', :git => 'git://github.com/rails/rails.git'

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

# Geocoding
gem "geokit"

# Simple pagination
gem "will_paginate"

# HAML!
gem 'haml', :git => 'git://github.com/nex3/haml.git', :tag => '3.0.0.beta.3'

# Required for rails_xss plugin, which turns on XSS protection by default;
# remove this (and the plugin) for Rails 3
gem "erubis"

# Importing & parsing stuff
gem "httparty"
gem "hpricot"

# Bundle gems used only in certain environments:
group :cucumber do
  gem "cucumber-rails"
  gem "database_cleaner"
  gem "webrat"
  gem "factory_girl"
end

group :test, :cucumber do
  # Bundle gems for certain environments:
  gem "rspec-rails", :git => "git://github.com/rspec/rspec-rails.git"
  gem "rspec", :git => "git://github.com/rspec/rspec.git"
  gem "rspec-core", :git => "git://github.com/rspec/rspec-core.git"
  gem "rspec-expectations", :git => "git://github.com/rspec/rspec-expectations.git"
  gem "rspec-mocks", :git => "git://github.com/rspec/rspec-mocks.git"
  gem "machinist"
  gem "ruby-debug"
  gem "spork"
  gem "webrat"
end
