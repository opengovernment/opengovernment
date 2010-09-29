source 'http://rubygems.org'

gem 'rails', '>= 3.0.0'

# ActiveRecord requires a database adapter.
gem "pg"
gem "mongo_mapper"
gem "bson_ext"

# Deployment
gem "capistrano"
gem "capistrano-ext"

# Config
gem 'settingslogic'

# An alternative form builder
gem "formtastic", :git => 'http://github.com/justinfrench/formtastic.git', :branch => 'rails3'

# Basic authentication
gem "devise"

# GIS & Geocoding
gem "GeoRuby"
gem "geokit"

# Breadcrumbs & navigation
gem "simple-navigation"

# Static pages
gem "high_voltage"

# Data import
# gem "govkit", :git => 'git://github.com/opengovernment/govkit.git' (SUBMODULE)
gem "chronic" # Complex date string parsing
#gem 'delayed_job', '~> 2.1.0.pre2'

# Simple pagination
gem "will_paginate", "~> 3.0.pre2"

# Attachments & assets
gem 'paperclip'
gem 'jammit'

# HAML!
gem 'haml', '>= 3.0.19'

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
group :test do
  # Bundle gems for certain environments:
  gem 'database_cleaner'
  gem 'launchy'    # So you can do "Then show me the page"
  gem 'rspec-rails', '>= 2.0.0.beta.22'
  gem 'spork'
  gem 'capybara'
  gem 'cucumber'
  gem 'cucumber-rails'
  gem "autotest"
  gem "autotest-rails"
  gem "factory_girl_rails"
  gem "machinist"
  gem "linecache19"
  gem "ruby-debug19"
end
