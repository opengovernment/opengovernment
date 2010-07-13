source 'http://rubygems.org'

gem 'rails', '3.0.0.beta4'

# ActiveRecord requires a database adapter.
gem "pg"

# An alternative form builder
gem "formtastic", :git => 'git://github.com/justinfrench/formtastic.git', :branch => 'rails3'

# Basic authentication
gem "clearance"

# GIS functionality
gem "GeoRuby"
gem "spatial_adapter"
gem "ym4r"

# Geocoding
gem "geokit"

# Data import
# gem "govkit", :git => 'git://github.com/opengovernment/govkit.git'
gem "chronic" # Complex date string parsing

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
gem 'hpricot_scrub', :git => 'git://github.com/UnderpantsGnome/hpricot_scrub.git'

# Indexing and Search
gem 'thinking-sphinx', :git     => 'git://github.com/freelancing-god/thinking-sphinx.git',
  :branch  => 'rails3',
  :require => 'thinking_sphinx'

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
