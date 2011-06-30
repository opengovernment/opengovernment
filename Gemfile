# -*- ruby -*-

source 'http://rubygems.org'

gem 'rake', '0.8.7'

# Using 3.0.7 until "Cannot modify SafeBuffer in place" bug is fixed...
gem 'rails', '3.0.7'

gem 'rack-contrib'
gem 'SystemTimer', :platforms => :ruby_18

# ActiveRecord requires a database adapter.
gem 'pg'
gem 'mongo_mapper'
gem 'bson_ext'

# Bulk data importing
gem 'activerecord-import'

# Rails.cache
gem 'memcache-client'
# gem 'memcached'

# Configuration/deploy management
gem 'settingslogic'
gem 'hoptoad_notifier'
gem 'capistrano'
gem 'capistrano-ext'
gem 'whenever', :require => false

# An alternative form builder
gem 'formtastic', '~> 1.1.0'

# Authentication
gem 'devise'
gem 'ruby_parser'

# GIS & Geocoding
gem 'GeoRuby'
gem 'geokit'
gem 'geoip'

# Breadcrumbs & navigation
gem 'simple-navigation'

# Static pages
gem 'high_voltage'

# Background tasks
gem 'delayed_job', '~> 2.1'

# Attachments & assets
gem 'paperclip'
gem 'jammit'
gem 'docsplit'

# Views & Javascript
gem 'haml'
gem "compass", ">= 0.11.1"
gem 'compass-960-plugin'
gem 'jquery-rails'

# JSON / APIs
gem 'rabl'
gem 'json'

# Tagging
gem 'acts-as-taggable-on'

# Importing & parsing stuff
gem 'httparty'
gem 'nokogiri'
gem 'chronic' # Complex date string parsing
gem 'fastercsv'
# gem 'govkit', :git => 'git://github.com/opengovernment/govkit.git' (SUBMODULE)

# Indexing and Search
gem 'thinking-sphinx', '~> 2.0.3'

# Pagination
gem 'kaminari'

# Graphics
gem 'googlecharts', '~> 1.6.1', :require => 'gchart'

# Bundle gems used only in certain environments:

group :production do
  # Logging
  gem 'SyslogLogger'
end

group :test, :development do
  gem 'database_cleaner'
  gem 'launchy'    # So you can do "Then show me the page"
  gem 'rspec-rails', '>= 2.0.0.rc'
  gem 'spork'
  gem 'capybara', '~> 0.4.1'
  gem 'cucumber', '~> 0.10.0'
  gem 'cucumber-rails', '~> 0.3.2'
  gem 'autotest'
  gem 'autotest-rails'
  gem 'factory_girl_rails'
  gem 'linecache', :platforms => :ruby_18
  gem 'linecache19', :platforms => :ruby_19
  gem 'ruby-debug', :platforms => :ruby_18
  gem 'ruby-debug19', :platforms => :ruby_19
  gem 'vcr', '~> 1.5.1'
  gem 'fakeweb', '~> 1.3.0'

  gem 'silent-postgres'	# Quieter postgres log messages
  gem 'rails_complete'	# Rails console tab completion; see https://github.com/dasch/rails-complete for install instructions
  gem 'hirb'
  gem 'awesome_print'
  gem 'guard'
  gem 'guard-livereload'
  gem 'rb-fsevent' 
end
