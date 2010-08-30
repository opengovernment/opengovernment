# TODO: When Rails 3 comes out, remove most of the :gits and other references to
# prerelease gems that are here for Rails 3 compatibility right now.

source 'http://rubygems.org'

gem 'rails', '>= 3.0.0'

# ActiveRecord requires a database adapter.
gem "pg"
gem "mongo_mapper"
gem "bson_ext"

# Deployment
gem "capistrano"
gem "capistrano-ext"

# An alternative form builder
gem "formtastic", :git => 'http://github.com/justinfrench/formtastic.git', :branch => 'rails3'

# Basic authentication
gem "clearance"

# GIS & Geocoding
gem "GeoRuby"
gem "spatial_adapter"
gem "geokit"

# Breadcrumbs
gem "simple-navigation"

# Data import
# gem "govkit", :git => 'git://github.com/opengovernment/govkit.git' (SUBMODULE)
gem "chronic" # Complex date string parsing

# Simple pagination
gem "will_paginate", "~> 3.0.pre2"

# Attachments & assets
gem "paperclip"
gem "jammit"

# HAML!
gem 'haml', '>= 3.0.18'

#Tagging
gem "acts-as-taggable-on", :git => 'http://github.com/mbleigh/acts-as-taggable-on.git'

# Importing & parsing stuff
gem "httparty"
gem "hpricot"
gem 'hpricot_scrub', :git => 'http://github.com/UnderpantsGnome/hpricot_scrub.git'

# Indexing and Search
gem 'thinking-sphinx', :git => 'http://github.com/freelancing-god/thinking-sphinx.git',
     :require => 'thinking_sphinx',
     :branch => 'rails3'

# Bundle gems used only in certain environments:
group :cucumber do
  gem "cucumber-rails"
  gem "database_cleaner"
  gem "factory_girl"
end

group :test, :cucumber do
  # Bundle gems for certain environments:
  gem "webrat", "~> 0.7.2.beta1"
  gem "rspec", ">= 2.0.0.beta.20"
  gem "rspec-core", ">= 2.0.0.beta.20", :require => 'rspec/core'
  gem "rspec-expectations", ">= 2.0.0.beta.20", :require => 'rspec/expectations'
  gem "rspec-mocks", ">= 2.0.0.beta.20", :require => 'rspec/mocks'
  gem "rspec-rails", ">= 2.0.0.beta.20", :require => 'rspec/rails'
  gem "autotest"
  gem "autotest-rails"
  gem "machinist"
  gem "linecache19"
  gem "ruby-debug19"
end
