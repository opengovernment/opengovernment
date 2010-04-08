OpenGovernment is a Ruby on Rails application for aggregating and presenting open government data.

# Requirements
Before you start, you will need to download and install the following:
   * PostgreSQL 8.4
   * [PostGIS](http://postgis.refractions.net/) (which requires the [proj4](http://trac.osgeo.org/proj/) and [geos](http://trac.osgeo.org/geos/) libraries)
   * Rails 2.3.x and Gem Bundler (the bundler gem)

# Installation
  * Create your database user and give it superuser privileges
  * Set up your config/database.yml and config/api_keys.yml (see api_keys.yml.example)
  * Run the following:

    bundle install
    rake install

  * Rake install will set up the database, install PostGIS, install fixtures, and download and install datasets.

To prepare the test database, run the following:
    rake db:test:prepare
    RAILS_ENV=test rake db:create:postgis
    RAILS_ENV=test rake spec:db:fixtures:load
