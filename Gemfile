# TODO: When Rails 3 comes out, remove most of the :gits and other references to
# prerelease gems that are here for Rails 3 compatibility right now.

source 'http://rubygems.org'

gem 'rails', '3.0.0.rc'

# ActiveRecord requires a database adapter.
gem "pg"

# Deployment
gem "capistrano"

# An alternative form builder
# gem "formtastic", :git => 'http://github.com/justinfrench/formtastic.git', :branch => 'rails3'

# Basic authentication
# gem "clearance"

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
gem "will_paginate", "~> 3.0.pre2"

# HAML!
# gem 'haml', :git => 'http://github.com/nex3/haml.git'

# Required for rails_xss plugin, which turns on XSS protection by default;
# remove this (and the plugin) for Rails 3
gem "erubis"

#Tagging
gem "acts-as-taggable-on", :git => 'http://github.com/mbleigh/acts-as-taggable-on.git'

# Importing & parsing stuff
gem "httparty"
gem "hpricot"
gem 'hpricot_scrub', :git => 'http://github.com/UnderpantsGnome/hpricot_scrub.git'

# async http requires (Ruby 1.9 only!)
#gem 'addressable', :require => 'addressable/uri'
#gem 'em-synchrony', :require => ['em-synchrony', 'em-synchrony/em-http']
#gem 'em-http-request', :git => 'http://github.com/igrigorik/em-http-request.git', :require => 'em-http'

# Indexing and Search
gem 'thinking-sphinx', :git => 'http://github.com/freelancing-god/thinking-sphinx.git',
     :require => 'thinking_sphinx',
     :branch => 'rails3'

# Bundle gems used only in certain environments:

group :cucumber do
  gem "cucumber-rails"
  gem "database_cleaner"
  gem "webrat"
  gem "factory_girl"
end

group :test, :cucumber do
  # Bundle gems for certain environments:
  gem "rspec-rails", ">= 2.0.0.beta.18"
  gem "rspec", ">= 2.0.0.beta.18"
  gem "rspec-core", ">= 2.0.0.beta.18"
  gem "rspec-expectations", ">= 2.0.0.beta.18"
  gem "rspec-mocks", ">= 2.0.0.beta.18"
  gem "autotest"
  gem "autotest-rails"
  gem "machinist"
  gem "linecache19"
  gem "ruby-debug19"
  gem "webrat"
end
