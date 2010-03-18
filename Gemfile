source :gemcutter

gem 'rails', '2.3.5'

# ActiveRecord requires a database adapter. By default,
# Rails has selected sqlite3.
gem "sqlite3-ruby", :require => "sqlite3"

# An alternative form builder
gem "formtastic"

# Basic authentication
gem "clearance"

# Required for rails_xss plugin, which turns on XSS protection by default;
# remove this for Rails 3
gem "erubis"

## Bundle gems used only in certain environments:
group :test do
   gem "cucumber-rails"
   gem "database_cleaner"
   gem "webrat"
   gem "rspec"
   gem "rspec-rails"
   gem "shoulda"
   gem "factory_girl"
end

group :cucumber do
   gem "cucumber-rails"
   gem "database_cleaner"
   gem "webrat"
   gem "rspec"
   gem "rspec-rails"
   gem "shoulda"
   gem "factory_girl"
end
