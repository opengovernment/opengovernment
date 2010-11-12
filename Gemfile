source 'http://rubygems.org'

gem 'rails'

# ActiveRecord requires a database adapter.
gem "pg"
gem "mongo_mapper"
gem "bson_ext"

# Rails.cache
gem 'memcache-client'
# gem 'memcached'

# Deployment
gem "capistrano"
gem "capistrano-ext"

# Config
gem 'settingslogic'

# An alternative form builder
gem 'formtastic', '~> 1.1.0'

# Authentication
gem "devise"
gem "ruby_parser"

# GIS & Geocoding
gem "GeoRuby"
gem "geokit"
gem 'geoip'

# Breadcrumbs & navigation
gem "simple-navigation"

# Static pages
gem "high_voltage"

# Background tasks

# This won't work with mongomapper v0.8.2.
# This commit fixes the bug: http://github.com/german/mongomapper/commit/9bed12e78880a4ddce90ca4a846090773bc8538d
gem 'delayed_job', '~> 2.1.0.pre2'

# Simple pagination
gem "will_paginate", "~> 3.0.pre2"

# Attachments & assets
gem 'paperclip'
gem 'jammit'
gem 'jquery-rails'

# HAML!
gem 'haml', '>= 3.0.19'

#Tagging
gem "acts-as-taggable-on", :git => 'http://github.com/mbleigh/acts-as-taggable-on.git'

# Importing & parsing stuff
gem "httparty"
gem "hpricot"
gem 'hpricot_scrub', :git => 'http://github.com/UnderpantsGnome/hpricot_scrub.git'
gem "chronic" # Complex date string parsing
gem 'json'
# gem "govkit", :git => 'git://github.com/opengovernment/govkit.git' (SUBMODULE)

# Indexing and Search
gem 'thinking-sphinx', :git => 'http://github.com/freelancing-god/thinking-sphinx.git',
     :require => 'thinking_sphinx',
     :branch => 'rails3'

group :development, :test do 
 gem 'silent-postgres' # Quieter postgres log messages
end

# Bundle gems used only in certain environments:
group :test do
  # Bundle gems for certain environments:
  gem 'database_cleaner'
  gem 'launchy'    # So you can do "Then show me the page"
  gem 'rspec-rails', '>= 2.0.0.rc'
  gem 'spork'
  gem 'capybara'
  gem 'cucumber'
  gem 'cucumber-rails'
  gem "autotest"
  gem "autotest-rails"
  gem "factory_girl_rails"
  gem "machinist"
  gem "linecache"
  gem "ruby-debug"
end
